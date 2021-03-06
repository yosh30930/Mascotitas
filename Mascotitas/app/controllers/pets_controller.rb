class PetsController < ApplicationController
  before_action :set_pet, :authenticate_user!, only: [:show, :edit, :update, :destroy]
  # GET /pets
  # GET /pets.json
  def index
    @pets = Pet.where(user_id:  current_user.id ).where.not(adoption: true).all
    @pets_a = Pet.where(user_id:  current_user.id ).where(adoption: true).all

  end

  def test
    puts 'TESTTTTTT'
    respond_to do |format|
          puts 'TESTTTTTT'
    puts params[:race]

      format.html { redirect_to adopcion_url, notice: 'COnsulta realizada' }
      format.json { head :no_content }
    end
  end

  # GET /pets/1
  # GET /pets/1.json
  def show
    @requests = Request.where(pet_id: params[:id]).all
    users_id = Array.new(@requests.size) 
    @requests.each do |req|
      users_id.push([req.interented_id])
    end
    @interested = User.find(users_id)
  end

  def adopta
    respond_to do |format|
      request = Request.new
      @pet = Pet.find(params[:id])
      request.interented_id = current_user.id
      request.pet_id = params[:id]
      request.publisher_id = @pet.user_id
      request.save



  RestClient.post "https://api:key-7cf8b365bc68f77363f9f6c3b0c10f16"\
  "@api.mailgun.net/v3/sandboxef86450b949b47ea8c0637234951d3a4.mailgun.org/messages",
  :from => "Mailgun Sandbox <postmaster@sandboxef86450b949b47ea8c0637234951d3a4.mailgun.org>",
  :to => @pet.user.email,
  :subject => "Mascotitas en adopcion",
  :text => "ALguien ha solicitado adoptar a una de tus mascotas, entra a tu perfil en MASCOTITAS."
      format.html { redirect_to pets_url, notice: 'Has dado de baja a tu mascota' }
      format.json { head :no_content }
    end
  end


  def adopcion
@ref = Pet.all
puts @ref.size

@pets = Pet.where("user_id != ? AND adoption = ? ", current_user.id, true)

    @pets = params[:race] ? @pets.where("race like ?", "%#{params[:race]}%" ) : @pets
    @pets = params[:name] ? @pets.where("name like ?", "%#{params[:name]}%") : @pets
    @pets = params[:specie] ? @pets.where(specie: params[:specie]) : @pets
    @pets = params[:gender] ? @pets.where(gender: params[:gender]) : @pets
    @pets = params[:size] ? @pets.where(size: params[:size]) : @pets
  
    @pets = params[:sterilized] ? @pets.where( sterilized: params[:sterilized]) : @pets

    i = 0
     @pets_m = Array.new(@pets.size) 
     @pets.each do |p|
       @pets_m[i] = [p.name,p.user.lat,p.user.lng,p.id]
       i = i+1 
     end

  end

  def acepta
      respond_to do |format|
        @request = Request.where(pet_id: params[:id]).first
        
        pet = Pet.where(id: @request.pet_id).first
        interested = User.where(id: @request.interented_id).first
        current_user.pets.delete(pet)
        current_user.save
        interested.pets << pet
        interested.save
        pet.adoption = false
        pet.user = interested
        pet.save
 
        @request.destroy


        format.html { redirect_to pets_url, notice: 'Diste una mascota en adopcion' }
        format.json { head :no_content }
      end
  end

  # GET /pets/new
  def new
    @pet = Pet.new
  end

  # GET /pets/1/edit
  def edit
  end

  # POST /pets
  # POST /pets.json
  def create
#   @pet = Pet.new(pet_params)
@pet = current_user.pets.create(pet_params)

    respond_to do |format|
      if @pet.save
        format.html { redirect_to @pet, notice: 'Has registrado a tu mascota' }
        format.json { render :show, status: :created, location: @pet }
      else
        format.html { render :new }
        format.json { render json: @pet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pets/1
  # PATCH/PUT /pets/1.json
  def update
    respond_to do |format|
      if @pet.update(pet_params)
        format.html { redirect_to @pet, notice: 'Has registrado a tu mascota' }
        format.json { render :show, status: :ok, location: @pet }
      else
        format.html { render :edit }
        format.json { render json: @pet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pets/1
  # DELETE /pets/1.json
  def destroy
    @pet.destroy
    respond_to do |format|
      format.html { redirect_to pets_url, notice: 'Has dado de baja a tu mascota' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pet
      @pet = Pet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pet_params
      params.require(:pet).permit(:name, :specie, :age, :gender, :race, :size, :sterilized, :avatar, :user_id, 
        :adoption, :moquillo, :rabia, :parainfluenza)
    end


end
