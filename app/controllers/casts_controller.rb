class CastsController < ApplicationController
  before_action :set_current_user
  before_action :set_cast_member, only: [:show, :edit, :update, :destroy]
  
  # Only allow Moderators to access management actions
  before_action :authorize_moderator!, except: [:show]

  def index
    @casts = Cast.all
  end

  def show
    # This remains public for all users
    @movies = @cast_member.movies.distinct
    @jobs = @cast_member.credits.where(cast_id: @cast_member.id).distinct.pluck(:job)
  end

  def new
    @cast = Cast.new
  end

  def create
    @cast = Cast.new(cast_params)
    if @cast.save
      redirect_to casts_path, notice: "Person added successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @cast_member.update(cast_params)
      redirect_to cast_path(@cast_member), notice: "Updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @cast_member.destroy
    redirect_to casts_path, notice: "Person removed from database."
  end

  private

  def set_cast_member
    @cast_member = Cast.find(params[:id])
  end

  def authorize_moderator!
    # Check your polymorphic identity
    unless @current_user&.actable_type == 'Moderator'
      redirect_to root_path, alert: "You do not have permission to manage cast members."
    end
  end

  def set_current_user
    @current_user = User.find(13)
  end

  def cast_params
    params.require(:cast).permit(:name, :pic, :bio)
  end
end