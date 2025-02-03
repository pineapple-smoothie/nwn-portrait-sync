class ConversionsController < ApplicationController
  def show
    @conversion = Conversion.find(params[:id])
  end

  def new
    @conversion = Conversion.new
  end

  def create
    @conversion = Conversion.new(conversion_params)
    @conversion.user = current_user

    if @conversion.save
      redirect_to conversion_path(@conversion), notice: "Conversion was successfully created."
    else
      flash.now[:alert] = "There was a problem with your image conversion."
      render :new, status: :unprocessable_entity
    end
  end

  def download
    @conversion = Conversion.find(params[:id])

    variants = {
      huge: @conversion.image.variant(:tga_huge).processed,
      large: @conversion.image.variant(:tga_large).processed,
      medium: @conversion.image.variant(:tga_medium).processed,
      small: @conversion.image.variant(:tga_small).processed,
      tiny: @conversion.image.variant(:tga_tiny).processed
    }

    temp_file = Tempfile.new([ "variants", ".zip" ])

    Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
      variants.each do |size, variant|
        variant_path = variant.service.path_for(variant.key)
        zipfile.add("portrait_#{size}.tga", variant_path)
      end
    end

    send_data File.read(temp_file.path),
              filename: "portrait_variants.zip",
              type: "application/zip",
              disposition: "attachment"

    temp_file.close
    temp_file.unlink
  end

  private

  def conversion_params
    params.require(:conversion).permit(:image)
  end
end
