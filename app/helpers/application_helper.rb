module ApplicationHelper
  def admin_route?
    request.path.start_with?('/admin')
  end
end
