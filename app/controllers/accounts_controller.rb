class AccountsController < ApplicationController
  ACCOUNTS_TOPIC_CUD = 'accounts_stream'
  ACCOUNTS_TOPIC_BE = 'accounts_lifecycle'

  before_action :set_account, only: [:edit, :update, :destroy]

  before_action :authenticate_account!, except: [:current]

  # GET /accounts
  def index
    @accounts = Account.order(:created_at).all
  end

  # GET /accounts/current.json
  # used by other services to get data per the strategy (see it under lib)
  def current
    render json: current_account.to_json
  end

  # GET /accounts/1/edit
  def edit
  end

  # PATCH/PUT /accounts/1
  def update
    respond_to do |format|
      new_role = @account.role != account_params[:role] ? account_params[:role] : nil

      if @account.update(account_params)
        # ----------------------------- produce event -----------------------
        message = {
          message_name: 'AccountUpdated',
          data: {
            id: @account.id,
            email: @account.email,
            full_name: @account.full_name,
            position: @account.position,
            role: @account.role
          }
        }
        Producer.new.publish(message, topic: ACCOUNTS_TOPIC_CUD)
        # --------------------------------------------------------------------

        produce_business_event(@account.id, new_role) if new_role

        # --------------------------------------------------------------------

        redirect_to root_path, notice: 'Account was successfully updated.'
      else
        render :edit
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  # in DELETE action, CUD event
  def destroy
    @account.update(active: false, disabled_at: Time.now)

    # ----------------------------- produce event -----------------------
    message = {
      type: 'AccountDeleted',
      data: { id: @account.id }
    }
    Producer.new.publish(message, topic: ACCOUNTS_TOPIC_CUD)
    # --------------------------------------------------------------------

    respond_to do |format|
      redirect_to root_path, notice: 'Account was successfully destroyed.'
    end
  end

  private

  def current_account
    if doorkeeper_token
      Account.find(doorkeeper_token.resource_owner_id)
    else
      super
    end
  end

  def set_account
    @account = Account.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def account_params
    params.require(:account).permit(:full_name, :role)
  end

  def produce_business_event(id, role)
    message = {
      type: 'AccountRoleChanged',
      data: { id: id, role: role }
    }
    Producer.new.publish(message, topic: ACCOUNTS_TOPIC_BE)
  end
end
