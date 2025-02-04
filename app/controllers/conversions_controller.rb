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
      redirect_to conversion_path(@conversion)
    else
      flash.now[:alert] = "There was a problem with your image conversion."
      render :new, status: :unprocessable_entity
    end
  end

  def download
    @conversion = Conversion.find(params[:id])
    conversion_downloader = ConversionDownloader.new(@conversion)

    # Add headers to prevent caching
    response.headers["Cache-Control"] = "no-cache"
    response.headers["Content-Type"] = "application/zip"
    response.headers["Content-Disposition"] = "attachment; filename=\"conversion_#{@conversion.id}.zip\""

    send_data(
      conversion_downloader.download,
      filename: "conversion_#{@conversion.id}.zip",
      type: "application/zip",
      disposition: "attachment",
      stream: true # Add streaming support
    )
  end

  private

  def conversion_params
    params.require(:conversion).permit(:image)
  end
end
