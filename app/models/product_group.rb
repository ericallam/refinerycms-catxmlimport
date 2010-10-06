class ProductGroup < ActiveRecord::Base
  has_many :products, :dependent => :destroy
  has_many :sales_features, :as => :featurable, :dependent => :destroy
  has_many :tech_spec_groups, :dependent => :destroy
  has_many :images, :as => :imagable, :class_name => 'CatImage', :dependent => :destroy

  has_friendly_id :name, :use_slug => true

  acts_as_tree

  def to_s
    self.name || 'unknown group name'
  end

  def tech_specs
    (parent.blank? ? ActiveSupport::OrderedHash.new : parent.tech_specs).tap do |hash|
      tech_spec_groups.each { |g| hash[g] = g.tech_specs }
    end
  end

  def default_image_url
    if image = images.detect {|img| img.thumbnail.file? }
      image.thumbnail.url(:category_page)
    else
      thumbnail_url = products.detect {|p| p.thumbnail_url(:category_page).present? }.try(:thumbnail_url, :category_page)
    
      thumbnail_url or '/images/related-products.png'
    end
  end

  def self.default_for_custom_product
    find_by_name('Attachments') or first
  end

  def sort_options(count)
    begin
      products.first.tech_specs.values.first.keys.first(count).map{|ts| [ts.name.upcase, ts.cat_id]}
    rescue
      []
    end
  end
end
