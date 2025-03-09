class ApiController < ActionController::API
  before_action :set_default_format

  private

  def set_default_format
    request.format = :json
  end

  def render_unauthorized
    render json: { error: 'You need to sign in before continuing' }, status: :unauthorized
  end

  def render_error(message, status = :unprocessable_entity)
    render json: { error: message }, status: status
  end

  def authenticate_user!
    unless user_signed_in?
      render_unauthorized
    end
  end
end
