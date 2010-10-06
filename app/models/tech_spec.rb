class TechSpec < ActiveRecord::Base

  belongs_to :tech_spec_group

  validates_presence_of :name
  validates_presence_of :cat_id

  acts_as_list :scope => :tech_spec_group

end
