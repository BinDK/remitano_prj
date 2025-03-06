class UsersController < ApplicationController
  before_action :set_user

  def sign_in_or_sign_up
    @user.present? ? handle_existing_user : handle_new_user

    redirect_to root_path
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
      flash[:notice] = 'Signed in successfully.'
    else
      flash[:alert] = 'Invalid email or password.'
    end
  end

  def handle_new_user
    user = User.new(user_params)

    if user.save
      sign_in(user)
      flash[:notice] = 'Account created and signed in successfully.'
    else
      flash[:alert] = "Error creating account: #{user.errors.full_messages.join(', ')}"
    end
  end
end
