# == Schema Information
#
# Table name: locations
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  state            :string(255)
#  city             :string(255)
#  street_first     :string(255)
#  street_second    :string(255)
#  default_location :boolean          default(FALSE)
#  opening_time     :datetime
#  closing_time     :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_locations_on_name  (name)
#

class Location < ActiveRecord::Base

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :state, :city, :opening_time, :closing_time, presence: true
  validates_with ShiftValidator

  has_many :orders
  has_many :inventory_items, dependent: :destroy
  has_many :ingredients, through: :inventory_items
  has_many :meals, ->{ distinct }, through: :ingredients

  # scope :default, -> { where(default_location: true).first }

  after_create :create_inventory_items
  before_save :ensure_single_default

  def available_meals
    meals.active.includes(:recipe_items).select { |meal| meal.quantity_available_by_location(self) }
  end

  def default
    Location.where(default_location: true).take
  end

  def set_default
    self.default_location = true
    save!
    return self
  end

  private

    def ensure_single_default
      if default_location
        begin
          current_default = default
          if current_default
            current_default.default_location = false
            current_default.save
          end
        rescue ActiveRecord::RecordNotFound
          return false
        end
      end
    end

    def create_inventory_items
      Ingredient.find_each do |ingredient|
        inventory_item = ingredient.inventory_items.new
        inventory_item.location_id = id
        inventory_item.quantity = 0
        inventory_item.save!
      end
    end
end
