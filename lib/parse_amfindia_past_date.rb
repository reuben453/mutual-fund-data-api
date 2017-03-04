require File.expand_path('../../config/environment',  __FILE__)

TABLE_HEADERS = ["Net Asset Value", "Repurchase Price", "Sale Price", "Upload Date"]
ITEM_HEADERS = ["net_asset_value", "repurchase_price", "sale_price", "upload_date"]




def get_historical_nav_page_for(date:)
  # uri = URI('http://portal.amfiindia.com/NavHistoryReport_Rpt_Po.aspx?rpt=0&frmdate=05-Dec-2016')
  uri = URI('http://portal.amfiindia.com/NavHistoryReport_Rpt_Po.aspx?rpt=0&frmdate=')
  if !File.file?("tmp/temp_mf_list_past_date_#{date.strftime('%d-%b-%Y')}.html")
    print "Fetching #{date.strftime('%d-%b-%Y')}"
    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Get.new(uri.request_uri + date.strftime('%d-%b-%Y'))

      http.request request do |response|
        open "tmp/temp_mf_list_past_date_#{date.strftime('%d-%b-%Y')}.html", 'wb' do |io|
          response.read_body do |chunk|
            io.write chunk
          end
        end
      end
    end
  else
    print "Already fetched #{date.strftime('%d-%b-%Y')}"
  end
end

# param page is a mechanize page
# missing_mfs is a list of known missing mfs, so that a message won't be
# printed if an mf on this list is not found, and any new missing mfs will be added to this list
def parse_historical_nav_html_page(page:, missing_mfs: [])
  rows = page.css('table table table tr')[1..-1]
  if rows.blank?
    print ", skipping empty"
    return
  else
    print ", #{rows.length - 1} entries"
  end
  # next if rows.blank?
  headers = rows.first.css('tr, th').collect(&:text)
  raise "Headers have changed to #{headers}" if headers != TABLE_HEADERS

  mf_name = nil
  rows[1..-1].css("tr:not(.label-BGC)").each_with_index do |r, index|
    items = r.css('th, td').collect(&:text).map(&:strip).reject(&:blank?).collect{|i| Nav::AMFINDIA_CSV_IGNORED_VALUES.include?(i) ? nil : i}
    next if items.blank?

    if items.length == 1
      mf_name = items.first
      next
    else
      mf = MutualFund.find_by(name: mf_name)
      if mf.blank?
        if !missing_mfs.include?(mf_name)
          print ", Missing mf #{mf_name}"
          missing_mfs.push(mf_name)
        end
        next
      end
      # raise "Error: Couldn't find mf for #{mf_name}" if mf.blank?

      items = ITEM_HEADERS.zip(items).to_h.with_indifferent_access
      net_asset_value = BigDecimal.new(items[:net_asset_value].to_s)
      repurchase_price = BigDecimal.new(items[:repurchase_price].to_s)
      sale_price = BigDecimal.new(items[:sale_price].to_s)
      date = items[:upload_date]

      begin
        mf.navs.create_if_missing!(mutual_fund: mf, date: date, net_asset_value: net_asset_value, repurchase_price: repurchase_price, sale_price: sale_price)
      rescue Nav::DifferentNavValues => e
        puts "Different nav values: #{e}"
        # missing_navs.push([mf.code, net_asset_value, repurchase_price, sale_price])
      rescue => e
        binding.pry
        print ", Failed to add nav #{net_asset_value} for mutual_fund #{mf.code}"
      end
    end
  end
end

missing_mfs = []
missing_navs = []

# start_date = Date.new(2010, 1, 1)
# end_date = Date.new(2016, 12, 25)

start_date = Date.parse(ARGV.first)
end_date = Date.parse(ARGV.second)

puts "This will download nav data from #{start_date} to #{end_date}, with the start and end dates included. Continue? (y/n)"

opt = STDIN.gets.chomp

if !['y', 'Y'].include?(opt)
  puts "Stopping since you typed '#{opt}' instead of 'y' or 'Y'"
else
  agent = Mechanize.new


  (start_date..end_date).each do |date|

    print "\n"

    get_historical_nav_page_for(date: date)

    # open("temp_mf_list_past_date.html") do |csv|
    #   binding.pry
    # end


    # binding.pry
    # date = Date.new(2016, 12, 5)

    page = agent.get("file:///#{Dir.pwd}/tmp/temp_mf_list_past_date_#{date.strftime('%d-%b-%Y')}.html")

    parse_historical_nav_html_page(page: page, missing_mfs: missing_mfs)

  end

  puts "\n\nMissing mfs: #{missing_mfs.uniq}"
  puts "\n\nMissing navs: #{missing_navs}"
end



# date = start_date.clone


puts "End"