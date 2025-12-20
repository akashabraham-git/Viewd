class CastController < ApplicationController
  def show
    @cast_member = Cast.find(params[:id])
    @movies = @cast_member.movies 
    @roles = @cast_member.credits.distinct.pluck(:role).join(", ")

  end
end