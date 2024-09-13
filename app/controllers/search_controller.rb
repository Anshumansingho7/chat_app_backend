class SearchController < ApplicationController

	def search
		if params[:search].present?
			users = User.search(params[:search], fields: [:email])
			render json: users.results
		else
			render json: { error: "Search term is missing" }, status: :bad_request
		end
	end	

end	
