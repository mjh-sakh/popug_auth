# frozen_string_literal: true

class Accounts::RegistrationsController < Devise::RegistrationsController
  ACCOUNTS_TOPIC_CUD = 'accounts_stream'

  def create
    super

    # ----------------------------- produce event -----------------------
    message = {
      message_name: 'AccountCreated',
      data: {
        id: resource.id,
        email: resource.email,
        full_name: resource.full_name,
        position: resource.position,
        role: resource.role
      }
    }
    Producer.new.publish(message, topic: ACCOUNTS_TOPIC_CUD)
    # --------------------------------------------------------------------
  end

  def sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[full_name])
    super
  end
end
