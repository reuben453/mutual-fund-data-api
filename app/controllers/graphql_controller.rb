class GraphqlController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_filter :verify_authenticity_token

  def query
    # 3. Execute queries with your schema
    result = Schema.execute(params[:query], variables: params[:variables])
    render json: result
  end
end