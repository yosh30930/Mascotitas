class RegistrationsController < Devise::RegistrationsController

  private

  def sign_up_params
  	puts "TEST EN DEVICE CONTROLLER"
    params.require(:user).permit(:name,:last_name, :phone_number,  :email, :password, :password_confirmation,:lat,:lng, )
  end

  #def account_update_params
  #  params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password)
  #end
end