class CharactersController < ApplicationController
  before_action :set_character, only: %i[ edit update destroy show ]

  after_action :verify_authorized

  # GET /characters or /characters.json
  def index
    authorize Character

    @characters = Character.all.order(:name).page(params[:page])
  end

  def mine
    authorize Character

    @characters = current_user.characters.order(:name).page(params[:page])
  end

  # GET /characters/new
  def new
    authorize Character

    @character = Character.new
    %w[huge].each do |size|
      @character.portraits.build(size: size)
    end
  end

  # GET /characters/1
  def show
    authorize @character
  end

  # GET /characters/1/edit
  def edit
    authorize @character
  end

  # POST /characters or /characters.json
  def create
    @character = Character.new(character_params)
    @character.user = current_user

    authorize @character

    if @character.save
      redirect_to mine_characters_path, notice: "Character was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /characters/1 or /characters/1.json
  def update
    authorize @character

    if @character.update(character_params)
      redirect_to mine_characters_path, notice: "Character was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /characters/1 or /characters/1.json
  def destroy
    authorize @character

    @character.destroy!

    respond_to do |format|
      format.html { redirect_to mine_characters_path, status: :see_other, notice: "Character was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def download_all_portraits
    authorize Character

    current_user.downloads.create!

    portrait_downloader = PortraitDownloader.new(Character.all)
    send_data portrait_downloader.download, filename: "all_portraits.zip"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_character
      @character = Character.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def character_params
      params
        .require(:character)
        .permit(
          :name,
          :user_id,
          :filename,
          portraits_attributes: [
            :id,
            :file,
            :size,
            :_destroy
          ]
        )
    end
end
