class CastsController < ApplicationController
  before_action :set_cast_member, only: [:show, :edit, :update, :destroy]
  before_action :authorize_moderator!, except: [:show, :index]

  def index
    @casts = Cast.all
  end

  def show
    @movies = @cast_member.movies.distinct
    @jobs = @cast_member.credits.where(cast_id: @cast_member.id).distinct.pluck(:job)
    @grouped_credits = @cast_member.credits.includes(:movie).group_by(&:job)
  end

  def new
    @cast = Cast.new
  end

  def create
    @cast = Cast.new(cast_params)
    if @cast.save
      redirect_to casts_path, notice: "Person added successfully."
    else
      flash.now[:alert] =  @cast.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @cast_member.update(cast_params)
      redirect_to cast_path(@cast_member), notice: "Updated successfully."
    else
      flash.now[:alert] =  @cast_member.errors.full_messages.to_sentence
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

  def cast_params
    params.require(:cast).permit(:name, :pic, :bio)
  end
end