class CharactersController < ApplicationController
  before_action :set_character, only: %i[ show edit update destroy ]

  # GET /characters or /characters.json
  def index
    @characters = Character.all
  end

  # GET /characters/1 or /characters/1.json
  def show
  end

  # GET /characters/new
  def new
    @character = Character.new
  end

  # GET /characters/1/edit
  def edit
  end

  # POST /characters or /characters.json
  def create
    @character = Character.new(character_params)
    @character.user = current_user

    respond_to do |format|
      if @character.save
        format.html { redirect_to @character, notice: "Character was successfully created." }
        format.json { render :show, status: :created, location: @character }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @character.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /characters/1 or /characters/1.json
  def update
    respond_to do |format|
      if @character.update(character_params)
        format.html { redirect_to @character, notice: "Character was successfully updated." }
        format.json { render :show, status: :ok, location: @character }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @character.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /characters/1 or /characters/1.json
  def destroy
    @character.destroy!

    respond_to do |format|
      format.html { redirect_to characters_path, status: :see_other, notice: "Character was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def download_all_portraits
    require "zip"

    compressed_filestream = Zip::OutputStream.write_buffer do |zos|
      Character.all.each do |character|
        next unless character.portrait.attached?

        [ :h, :l, :m, :s, :t ].each do |variant_name|
          filename = "#{character.name}_#{variant_name}.tga"
          zos.put_next_entry(filename)
          variant = character.portrait.variant(variant_name).processed
          zos.write variant.download
        end
      end
    end

    compressed_filestream.rewind
    send_data compressed_filestream.read, filename: "all_portraits.zip"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_character
      @character = Character.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def character_params
      params.expect(character: [ :name, :user_id, :portrait ])
    end
end
