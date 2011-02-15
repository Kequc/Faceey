class ProfilePictureUploader < CarrierWave::Uploader::Base
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
  version :thumb do
    process :resize_to_fill => [50, 50]
  end
  version :big do
    process :resize_to_limit => [200, nil]
  end

  def extension_white_list
    %w(jpg jpeg gif png tiff)
  end
end
