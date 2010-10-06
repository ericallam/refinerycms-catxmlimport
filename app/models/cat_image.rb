class CatImage < ActiveRecord::Base
  extend S3AttachedFile

  belongs_to :imagable, :polymorphic => true

  THUMBNAIL_TYPES = %w(large_working_shot large_model_view large_image large_web_model_view)
  DOCUMENT_TYPES = %w(specalog_pdf tech_spec_graphic)
  
  # this method is defined in lib/s3_attached_file, 
  # and wraps paperclips has_attached_file with s3 options
  # s3 credentials are symlinked to config/s3_credentials.yml
  # in staging and production.
  has_attached_s3_file :thumbnail, :styles => { 
      :slideshow      => '41x41#',
      :product_list   => '82x82#',
      :category_page  => '131x131#',
      :quote_dropdown => '92x60#',
      :quote_request  => '144x91#',
      :main           => '296x205#'
    }

  has_attached_s3_file :document

  after_create :create_thumbnail
  before_save :save_new_thumbnail, :if => :url_changed_and_not_already_fetched?

  validates_attachment_size :thumbnail, 
    :in => (1..1.megabyte), 
    :message => 'must be smaller than 1 megabyte',
    :if => :validate_thumbnail?

  validates_attachment_content_type :thumbnail, 
    :content_type => %w(image/jpg image/jpeg image/x-png image/png image/gif image/pjpeg),
    :if => :validate_thumbnail?

  def thumbnailable?
    THUMBNAIL_TYPES.include?(self.image_type)
  end

  def documentable?
    DOCUMENT_TYPES.include?(self.image_type)
  end

  DISPLAY_NAMES = {'specalog_pdf' => 'Product Spec', 'tech_spec_graphic' => 'Product Diagram'}

  def display_name
    DISPLAY_NAMES[self.image_type] || 'Image'
  end

  def document_url
    if document.file?
      document.url
    else
      self.url
    end
  end

  # if this image doesn't thumbnail files
  # just return the url attribute
  # used in products/show.html.erb
  def thumbnail_url_with_default(type)
    if self.thumbnail.file?
      self.thumbnail.url(type)
    else
      self.url
    end
  end

  private

  def validate_thumbnail?
    thumbnailable? and self.thumbnail.file?
  end

  def create_thumbnail
    return if self.thumbnail.file?

    fetch_url_and_create_thumbnails

    self.save
  end

  def save_new_thumbnail
    return if self.new_record?

    return if self.thumbnail.file? && !self.url_changed?

    fetch_url_and_create_thumbnails
  end

  def fetch_url_and_create_thumbnails
    return unless self.thumbnailable? # guard against the wrong image_type

    begin
      @fetched = true # so we don't end up in an save infinite-loop

      if temp_file = ThumbnailFetcher.new(self.url).fetch
        self.thumbnail = temp_file
      end

    rescue ThumbnailFetcher::FetchError => e
      # TODO handle this error differently?
      raise e
    end
  end

  def url_changed_and_not_already_fetched?
    self.url_changed? && !@fetched
  end
end
