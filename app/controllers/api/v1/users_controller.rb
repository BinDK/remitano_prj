class Api::V1::UsersController < ApiController
  before_action :set_user, only: :sign_in_or_sign_up

  def sign_in_or_sign_up
    @user.present? ? handle_existing_user : handle_new_user
  end

  def current
    if user_signed_in?
      render json: { user: current_user.as_json(only: %i[id email]) }
    else
      render json: { user: nil }
    end
  end

  def logout
    if user_signed_in?
      sign_out(current_user)
      render json: { success: true }
    else
      render json: { success: false }
    end
  end

  private

  def set_user
    @user = User.find_by(email: user_params[:email])
  end

  def user_params
    permitted_params = params.require(:user).permit(:email, :password)
    permitted_params[:password_confirmation] = permitted_params[:password]
    permitted_params
  end

  def handle_existing_user
    if @user.valid_password?(user_params[:password])
      sign_in(@user)
      render json: { success: true, user: @user.as_json(only: %i[id email]) }
    else
      render_error('Invalid email or password', :unauthorized)
    end
  end

  def handle_new_user
    user = User.new(user_params)

    if user.save
      sign_in(user)
      render json: { success: true, user: user.as_json(only: %i[id email]) }
    else
      render_error(user.errors.full_messages.join(', '))
    end
  end
end
