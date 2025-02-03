require "zip"

class PortraitDownloader
  def initialize(characters)
    @characters = characters
  end

  def download
    compressed_filestream = Zip::OutputStream.write_buffer do |zos|
      @characters.each do |character|
        character.portraits.each do |portrait|
          next unless portrait.file.attached?

          filename = "#{character.filename}#{portrait.size.first.upcase}.tga"
          zos.put_next_entry(filename)

          # Get the original TGA file
          tga_data = portrait.download_tga
          next unless tga_data

          zos.write tga_data.download
        end
      end
    end

    compressed_filestream.rewind
    compressed_filestream.read
  end
end
