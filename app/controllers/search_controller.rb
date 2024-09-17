class SearchController < ApplicationController

	def search
		if params[:search].present?
			users = User.search(params[:search], fields: [:email])
			render json: users.results
		else
			render json: { error: "Search term is missing" }, status: :bad_request
		end
	end	

  def current_user
    jwt_payload = JWT.decode(request.headers['Authorization'].split( ' ' )[1], Rails.application.credentials.fetch(:secret_key_base)).first
    current_user = User.find(jwt_payload['sub'])
    if current_user
      render json: {
        status: 200,
        user: current_user
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "User has no active session"
      }, status: :unauthorized
    end
  end

end	
