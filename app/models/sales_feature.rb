class SalesFeature < ActiveRecord::Base
  belongs_to :featurable, :polymorphic => true
end
