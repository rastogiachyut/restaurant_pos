class OrdersController < ApplicationController

  before_action :ensure_logged_in
  before_action :set_order, only: [:show, :place]
  before_action :check_cancelable, only: [:destroy]

  def show
    @line_items = @order.line_items
  end

  def details
    @user = current_user
    @order = @user.orders.where(id: params[:id]).take
    @transaction = @order.transactions.first
  end

  def destroy
    #FIXME_AB: what if it is not cancled? 
    @order.mark_canceled
    #FIXME_AB: no notice for user 
    redirect_to user_orders_path(@user)
  end

  def index
    @user = current_user
    @orders = @user.orders.where.not(status: "pending").includes(:location)
  end

  def place
    @user = current_user
    customer = @user.stripe_customer(params[:stripeToken])

    charge = Stripe::Charge.create(
      customer:    customer.id,
      amount:      @order.price_in_cents,
      description: "Order Id is: #{ @order.id }",
      currency:    'usd'
    )

    if @order.mark_paid(charge, params)
      redirect_to details_user_order_path(@user, @order), notice: 'Your order has been successfully placed!'
    else
      @order.transactions.first.refund
      redirect_to :back, alert: "The order could not be placed because of the following errors. \n #{@order.errors.full_messages.join(', ')}"
    end

    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to :back

  end

  private

    def check_cancelable
      @user = current_user
      @order = @user.orders.where(id: params[:id]).take
      #FIXME_AB: not needed here, move it to mark_canceled
      if !@order.cancelable?
        redirect_to user_orders_path(@user), alert: 'This order cannot be canceled, either because time restriction or status!'
      end
    end

    def set_order
      @order = current_order
    end

end
