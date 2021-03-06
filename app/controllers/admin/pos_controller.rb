class Admin::PosController < Admin::BaseController
  layout 'pos'

  before_action :set_location
  before_action :set_location_order, only: [:show, :cancel]

  def index
    @orders = @location.orders.not_pending.order(:pickup_time).includes(:user)
  end

  def show
    @transaction = @order.transactions.first
  end

  def deliver
    @order = @location.orders.where(id: params[:order_id]).take
    if @order.mark_delivered
      redirect_to :back, notice: "Order ID:#{@order.id} was delivered!"
    else
      redirect_to :back, alert: "Unable to mark order ID:#{@order.id} as delivered due to the following reasons. #{@order.errors.full_messages.join(', ')}"
    end
  end

  def cancel
    if @order.mark_canceled
      redirect_to :back, notice: "Order #{@order.id} has been cancled."
    else
      redirect_to :back, alert: "Order #{@order.id} could not be cancled, because of time restriction ,status or errors. #{@order.errors.full_messages.join(', ')}."
    end
  end

  private

    def set_location
      if params[:location_name].nil?
        @location = Location.where(id: params[:location_id]).take
      else
        @location = Location.where(name: params[:location_name]).take
      end
      if @location.nil?
        redirect_to :back, alert: "Unable to find location in #{params}."
      end
    end

    def set_location_order
      @location = Location.where(id: params[:location_id]).take
      @order = @location.orders.where(id: params[:order_id]).take
      # @order = Order.where(id: params[:order_id]).take
    end

end
