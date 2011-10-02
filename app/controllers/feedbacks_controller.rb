# encoding: UTF-8
class FeedbacksController < ApplicationController
  before_filter :check_offline

  def index
  end

  def new
    @comment, @name, @email, @tel = '', '', '', ''
    if current_user
      @name = "#{current_user.first_name} #{current_user.last_name}"
      @email = "#{current_user.email}"
    end
  end

  def create
    @comment = params[:comment]
    @name = params[:name]
    @email = params[:email]
    @tel = params[:tel]
    unless @comment.blank?
      FeedbackMailer.feedback_mail(@comment, @name, @email, @tel, current_user).deliver
      flash[:success] = 'Kiitos palautteesta'
      redirect_to feedbacks_path
    else
      flash[:error] = 'Älä unohda kirjoittaa palautetta'
      render :new
    end
  end

  private
  def check_offline
    render :offline if offline?
  end
end
