# app/controllers/api/v1/casts_controller.rb
module Api
  module V1
    class CastsController < BaseController
      skip_before_action :doorkeeper_authorize!, only: [:show, :index]
      before_action :set_cast_member, only: [:show, :update, :destroy]
      before_action :authorize_moderator!, except: [:show, :index]

      def index
        @casts = Cast.all
        render 'api/v1/casts/index'
      end

      def show
        @movies = @cast_member.movies.distinct
        @jobs = @cast_member.credits.where(cast_id: @cast_member.id).distinct.pluck(:job)
        @grouped_credits = @cast_member.credits.includes(:movie).group_by(&:job)
        
        render 'api/v1/casts/show'
      end

      def create
        @cast = Cast.new(cast_params)
        
        if @cast.save
          
          render 'api/v1/casts/show', status: :created
        else
          render_error(@cast.errors.full_messages.to_sentence)
        end
      end

      def update
        if @cast_member.update(cast_params)
          render 'api/v1/casts/show', status: :ok
        else
          render_error(@cast_member.errors.full_messages.to_sentence)
        end
      end

      def destroy
        @cast_member.destroy
        render_success("Person removed from database", :ok)
      end

      private

      def set_cast_member
        @cast_member = Cast.find_by(id: params[:id])
        return render_error("Cast member not found", :not_found) if @cast_member.nil?
      end

      def cast_params
        params.require(:cast).permit(:name, :pic, :bio)
      end
    end
  end
end