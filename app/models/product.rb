class Product < ActiveRecord::Base
  belongs_to  :product_group

  has_friendly_id :display_name, :use_slug => true

  has_many :tech_spec_values, :dependent => :destroy
  has_many :sales_features, :as => :featurable, :dependent => :destroy
  has_many :images, :as => :imagable, :class_name => 'CatImage', :dependent => :destroy

  accepts_nested_attributes_for :images, :reject_if => proc{|attrs|
    attrs[:thumbnail].blank? && attrs[:document].blank? && attrs[:id].blank?
  }, :allow_destroy => true

  accepts_nested_attributes_for :tech_spec_values, :reject_if => proc{|attrs|
    attrs[:english_value].blank? && attrs[:metric_value].blank? && attrs[:text_value].blank?
  }

  has_and_belongs_to_many :related,
    :class_name               => 'Product',
    :foreign_key              => 'product_id',
    :association_foreign_key  => 'related_product_id',
    :join_table               => 'related_products'

  acts_as_indexed :fields => [:long_name, :name, :non_display_name, :product_group_name],
                  :index_file => [Rails.root.to_s, "tmp", "index"]

  # default_scope :order => 'long_name, products.name, non_display_name'
  scope :search, lambda { |query| where(['long_name LIKE ? OR products.name LIKE ?', "%#{query}%", "%#{query}%"]) }
  scope :any_category, joins(:product_group).where('product_groups.application_category_id IS NOT NULL')
  scope :for_category, lambda { |category| joins(:product_group).where(['product_groups.application_category_id = ?', category.id]) }

  scope :seeds, where(:seed => true)

  after_save :clear_old_tech_spec_values, :if => :product_group_id_changed?

  def to_s
    display_name
  end

  def display_name
    self.long_name || self.name || self.non_display_name || nil
  end

  def default_image
    find_image_type('large_web_model_view') || 
    find_image_type('large_working_shot') || 
    find_image_type('large_model_view') || 
    find_image_type('large_image') || 
    images.last
  end

  # returns thumbnail urls stored on s3 or the filesystem
  # or if none exist, returns the default_image url
  def thumbnail_url(thumbnail_type)
    image = find_image_with_thumbnail_of_type('large_web_model_view') || 
            find_image_with_thumbnail_of_type('large_working_shot') ||
            find_image_with_thumbnail_of_type('large_model_view') ||
            find_image_with_thumbnail_of_type('large_image')

    if image
      image.thumbnail.url(thumbnail_type) 
    else
      default_image.try(:url) || '/images/related-products.png'
    end
  end

  # used in products/show.html.erb in the Documents section
  def spec_document
    @spec_document ||= find_image_type('specalog_pdf')
  end  

  # used in products/show.html.erb in the Documents section
  def diagram
    @diagram ||= find_image_type('tech_spec_graphic')
  end

  # this will return images that have thumbnail files stored
  # and that have image_types in CatImage::THUMBNAIL_TYPES
  def thumbnailed_images
    @thumbnailed_images ||= images.select {|img| img.thumbnailable? && img.thumbnail.file? }
  end

  # this will return images that have image_types in CatImage::THUMBNAIL_TYPES
  def thumbnailable_images
    @thumbnailed_images ||= images.select {|img| img.thumbnailable? }
  end

  def document_images
    @document_images ||= images.select {|img| img.documentable? }
  end

  def tech_specs
    product_group.tech_specs.tap do |group_hash|
      group_hash.each_pair do |key, value_array|
        value_hash = ActiveSupport::OrderedHash.new
        value_array.each do |tech_spec|
          value_hash[tech_spec] = tech_spec_value_for(tech_spec)
        end
        group_hash[key] = value_hash
      end
    end
  end

  def tech_spec_value_for(tech_spec)
    tech_spec_values.select {|v| v.cat_id == tech_spec.cat_id}.first
  end

  def product_group_name
    product_group.try(:name)
  end
  

  private

  def clear_old_tech_spec_values
    self.tech_spec_values.each do |tech_spec_value|
      if tech_spec_value.tech_spec.tech_spec_group.product_group_id != self.product_group_id
        tech_spec_value.destroy
      end
    end
  end

  def long_name_blank?
    self.long_name.blank?
  end

  def name_blank?
    self.name.blank?
  end

  def find_image_with_thumbnail_of_type(type)
    images.detect {|img| img.thumbnailable? && img.thumbnail.file? && img.image_type =~ /#{type}/}
  end


  def find_image_type(type)
    images.select {|img| img.image_type =~ /#{type}/}.first
  end
end
