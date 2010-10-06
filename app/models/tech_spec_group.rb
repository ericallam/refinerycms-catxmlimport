class TechSpecGroup < ActiveRecord::Base

  belongs_to :product_group
  has_many :tech_specs, :order => :position, :dependent => :destroy

  validates_presence_of :cat_id

end
