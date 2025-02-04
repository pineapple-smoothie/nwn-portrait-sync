require "zip"

class ConversionDownloader
  def initialize(conversion)
    @conversion = conversion
  end

  def download
    compressed_filestream = Zip::OutputStream.write_buffer do |zos|
      # Get all variants for this conversion

      variants = [ :tga_huge, :tga_large, :tga_medium, :tga_small, :tga_tiny ]
      labels = [ "converted_H", "converted_L", "converted_M", "converted_S", "converted_T" ]

      variants.zip(labels).each do |variant, label|
        zos.put_next_entry("#{label}.tga")
        zos.write @conversion.image.variant(variant).processed.download
      end
    end

    compressed_filestream.rewind
    compressed_filestream.read
  end
end
