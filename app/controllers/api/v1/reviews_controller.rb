module Api
  module V1
    class ReviewsController < ActionController::API
      before_action :set_review, only: [:show, :update, :destroy]

      def index
        if params[:movie_id]
          @movie = Movie.find(params[:movie_id])
          @reviews = @movie.reviews.includes(member: :user)
        elsif params[:user_id]
          @user = User.find(params[:user_id])
          @reviews = @user.member.reviews.includes(:movie)
        else
          @reviews = Review.all.limit(20)
        end
      end

      def show
      end

      def create
        @movie = Movie.find(params[:movie_id])
        @review = @movie.reviews.build(review_params)
        
        if @review.save
          render :show, status: :created
        else
          render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @review.update(review_params)
          render :show, status: :ok
        else
          render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @review.destroy
        head :no_content
      end

      private

      def set_review
        @review = Review.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Review not found" }, status: :not_found
      end

      def review_params
        params.require(:review).permit(:content, :rating, :member_id)
      end
    end
  end
end