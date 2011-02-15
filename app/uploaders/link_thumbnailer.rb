class LinkThumbnailer < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "links/#{model.id}"
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  process :resize_to_fill => [35, 35]

  def extension_white_list
    %w(jpg jpeg gif png tiff)
  end
end
