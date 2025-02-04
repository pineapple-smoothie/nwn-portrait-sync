require "zip"

class PortraitDownloader
  def initialize(characters)
    @characters = characters
  end

  def download
    compressed_filestream = Zip::OutputStream.write_buffer do |zos|
      @characters.each do |character|
        # Get all portraits for this character
        character.portraits.each do |portrait|
          next unless portrait.file.attached?

          # Use the character's filename and the portrait size's abbreviation
          filename = "#{character.filename}#{portrait.type[:abbreviation]}.tga"
          zos.put_next_entry(filename)

          # Download the original TGA file
          zos.write portrait.file.download
        end
      end
    end

    compressed_filestream.rewind
    compressed_filestream.read
  end
end
