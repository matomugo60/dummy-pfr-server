class ApplicationController < Sinatra::Base
  set :default_content_type, "application/json"
   enable :session


  post "/user/register" do
    begin
      user = User.create(
        name: params[:name],
        email: params[:email],
        location: params[:location],
        password: params[:password],
        password_confirmation: params[:password_confirmation],
      )
     
      if user.valid?
        session[:user_id] = user.id
        { message: "User added!" }.to_json
      else
        { error: user.errors.full_messages }.to_json
      end
    rescue ActiveRecord::RecordNotUnique => e
      { error: "Email address in use" }.to_json
    rescue ActiveRecord::RecordInvalid => e
      { error: e.record.errors.full_messages.join(", ") }.to_json
    rescue => e
      { error: "Registration not successfull" }.to_json
    end
  end


  post "/user/login" do
    user = User.find_by(email: params[:email])
    if user.nil?
      { error: "User not found" }.to_json
    elsif user.authenticate(params[:password])
      session[:user_id] = user.id
      { message: "Logged in successfully" }.to_json
    else
      { error: "Incorrect password" }.to_json
    end
  end
  

  post "/user/logout" do
    session[:user_id] = nil
    { message: "Logged out successfully" }.to_json
  rescue StandardError => e
    { error: e.message }.to_json
  end


 post "/add/pet/:id" do
  user = User.find_by(id: params[:id])

  if user
    pet = Pet.new(
      name: params[:name],
      breed: params[:breed],
      age: params[:age],
      image: params[:image],
      species: params[:species],
      description: params[:description],
      user_pet_ids: user.id
    )
       
    if pet.save
      status 201
      { message: "Pet added !" }.to_json
    else
      status 422
      { error: "Failed" }.to_json
    end
  else
    status 422
    { error: "Logged in to add a pet" }.to_json
  end
end


  get "/pets" do
    pets = Pet.all
    pets.to_json
  end
  

get "/pets/user/:id" do
  user = User.find_by(id: session[:user_id])
  if user
    pet = user.pets.first
    if pet
      { message: "Your pets", pet: pet }.to_json
    else
      { message: "No pets added" }.to_json
    end
  else
    { error: "Loggin to view your pets" }.to_json
  end
rescue => e
  { error: e.message }.to_json
end


  get "/pets/search/name/:name" do
    begin
      pets = Pet.where("name LIKE ?", "#{params[:name]}%")
      pets.to_json
    rescue => e
      { error: e.message }.to_json
    end
  end
  

  get "/pets/search/breed/:breed" do
    begin
      pets = Pet.where("breed LIKE ?", "#{params[:breed]}%")
      pets.to_json
    rescue StandardError => e
      { error: e.message }.to_json
    end
  end

 
 put "/pets/update/:id" do
  begin
    pet = Pet.find_by(id: params[:id])
    if pet
      if pet.user_pet_ids.include?(session[:user_id])
        pet.user_pet_ids << params[:new_user_id].to_i
        pet.update(
          name: params[:name],
          breed: params[:breed],
          age: params[:age],
          description: params[:description],
          image: params[:image],
          species: params[:species]
        )
        { message: "Pet updated !" }.to_json
      else
        status 403
        { error: "You cannot update this pet" }.to_json
      end
    else
      status 404
      { error: "Pet not found" }.to_json
    end
  rescue StandardError => e 
    status 500
    { error: e.message }.to_json
  end
end


get '/users' do
  users = User.all
  users.to_json(include: [:pets])

end


delete "/pets/delete/:id" do
  begin
    pet = Pet.find_by(id: params[:id])
    if pet
      if pet.user_pet_ids.include?(session[:user_id])
        user_pet = UserPet.where(user_id: session[:user_id], pet_id: pet.id).first
        user_pet.destroy if user_pet
        pet.destroy
        { message: "Pet deleted!" }.to_json
      else
        { error: "You cannot delete this pet" }.to_json
      end
    else
      { error: "Pet not found" }.to_json
    end
  rescue => e
    { error: e.message }.to_json
  end
end

end
