require "zip"

class PortraitDownloader
  def initialize(characters)
    @characters = characters
  end

  def download
    compressed_filestream = Zip::OutputStream.write_buffer do |zos|
      @characters.each do |character|
        next unless character.portrait.attached?

        [ :h, :l, :m, :s, :t ].each do |variant_name|
          filename = "#{character.filename}#{variant_name.upcase}.tga"
          zos.put_next_entry(filename)

          variant = character.portrait.variant(variant_name).processed

          zos.write variant.download
        end
      end
    end

    compressed_filestream.rewind

    compressed_filestream.read
  end
end
