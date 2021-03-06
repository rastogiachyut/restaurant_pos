class Admin::InventoryItemsController  < Admin::BaseController
  before_action :set_inventory_item, only: [:show, :increase_quantity, :decrease_quantity]
  before_action :set_resource, only: [:index]

  def index
    @inventory_items = @resource.inventory_items.includes(:ingredient, :location)
  end

  def increase_quantity
    @status = @inventory_item.increase_quantity(params[:increase_quantity].to_i)
    render_json_response
  end

  def decrease_quantity
    @status = @inventory_item.decrease_quantity(params[:decrease_quantity].to_i)
    render_json_response
  end

  private

    def render_json_response
      if @status
        render json: { status: 'success', qty: @inventory_item.quantity }
      else
        render json: { status: 'error', errors: @inventory_item.errors.full_messages }
      end
    end

    def set_resource
      if params[:location_id].present?
        @resource = Location.where(id: params[:location_id]).take
      else
        @resource = Ingredient.where(id: params[:ingredient_id]).take
      end
    end

    def set_inventory_item
      begin
        @inventory_item = InventoryItem.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        redirect_to admin_inventory_items_path, notice: "No inventory_item with id #{ params[:id] } found!"
        return
      end
    end

    def inventory_item_params
      params.require(:inventory_item).permit(:ingredient_id, :location_id, :quantity)
    end
end
