module ApplicationHelper
  def can_manage(submission)
    puts "current", current_user
    current_user and (submission.user == current_user or current_user.admin?)
  end

  def verify_manager
    if !can_manage(@submission)
      puts "NSIVdvnmksdvmdlvs"
    end
    redirect_to root_path unless can_manage(@submission)
  end

  def user_is_admin
    current_user and current_user.admin?
  end

  def require_admin
    redirect_to root_path unless user_is_admin
  end

  def get_request_ip
    request.headers['X-Forwarded-For'] || request.ip
  end
end
