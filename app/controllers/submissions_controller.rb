class SubmissionsController < ApplicationController
  before_action :set_submission, only: [:show, :edit, :update, :destroy, :deny, :approve, :download]
  respond_to :html, :xml, :json
  before_filter :authenticate_user!, only: [:new, :edit, :create, :update, :destroy, :approve, :deny]
  before_filter :verify_manager, only: [:edit, :destroy, :update]

  def index
    if params[:user]
      @user = User.where(:username => params[:user]).first
      @submissions = Submission.where(:user => @user)
      @submissions = if params[:sort] == "newest" || !params[:sort]
        @submissions.desc(:created_at)
      elsif params[:sort] == "popular"
        @submissions = @submissions.desc(:download_count)
      end
      @submissions = @submissions.page(params[:page]).per(8)
    else
      @type = params[:type]
      projects = Submission.all
      if params[:type]
        projects = projects.where(:type => type_for(@type))
      else
        @type = "All"
      end
      projects = if params[:sort] == "newest" || !params[:sort]
        projects.desc(:created_at)
      elsif params[:sort] == "popular"
        projects = projects.desc(:download_count)
      end
      @submissions = Array.new
      projects.each { |submission| @submissions << submission if submission.ready? }
      @submissions = Kaminari.paginate_array(@submissions).page(params[:page]).per(8)
    end
  end

  def download
    @submission.download_count = @submission.download_count + 1
    @submission.save
    send_file @submission.latest_download.download.path
  end

  def show
    respond_with(@submission)
  end

  def new
    @submission = Submission.new
    respond_with(@submission)
  end

  def edit
  end

  def create
    @submission = Submission.new(submission_params)
    current_user.submissions << @submission
    @submission.save
    respond_with(@submission)
  end

  def update
    @submission.update(submission_params)
    respond_with(@submission)
  end

  def destroy
    @submission.destroy
    redirect_to submissions_path
  end

  private
  def type_for(type)
    if type == "models"
      return "Asset"
    elsif type == "levels"
      return "Level"
    else
      return "Level"
    end
  end

  def set_submission
    @submission = Submission.find(params[:id] || params[:submission_id])
  end

  def submission_params
    params.require(:submission).permit(:name, :downloads, :body, :type)
  end
end
