class CastController < ApplicationController
  def show
    @cast_member = Cast.find(params[:id])
    @movies = @cast_member.movies.distinct
    @jobs = @cast_member.credits.distinct.pluck(:job)
  end
end