class PictureUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "pictures/#{model.id}"
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  process :resize_to_limit => [750, 600]

  version :tiny do
    process :resize_to_fill => [35, 35]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
