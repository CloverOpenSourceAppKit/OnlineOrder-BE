class OrdersController < ApplicationController
  def create
    # create order on server
    order = Order.create_order_on_COS(params)
    Order.send_notification(order)
    render json: {order: order}
  end

  def update
  end

  def index
    @orders = Order.where(mid: params[:mid])
    render json: @orders
  end

  private
  def order_params
    # lineItems => array of objects containing uuid, qty
    params.require(:order).permit(:lineItems, :qty)
  end

end
