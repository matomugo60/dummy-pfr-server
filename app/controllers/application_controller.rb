class ApplicationController < Sinatra::Base
    set :default_content_type, "application/json"
    enable :sessions

    get '/' do
        "Hello World"
      end

    post "/user/register" do
        begin
          user =
            User.create(
              name: params[:name],
              email: params[:email],
              location: params[:location],
              password: params[:password],
              password_confirmation: params[:password_confirmation],
            )
          if user.valid?
            session[:user_id] = user.id
            { message: "User created successfully" }.to_json
          else
            { error: user.errors.full_messages }.to_json
          end
        rescue ActiveRecord::RecordNotUnique => e
          { error: "Email address already registered" }.to_json
        rescue ActiveRecord::RecordInvalid => e
          { error: e.record.errors.full_messages.join(", ") }.to_json
        rescue => e
          { error: "Regestration failed" }.to_json
        end
      end

      
      post "/user/login" do
        user = User.find_by(email: params[:email])
        if user && user.authenticate(params[:password])
          session[:user_id] = user.id
          { message: "Logged in successfully" }.to_json
        else
          { error: "Invalid email or password" }.to_json
        end
      end


      post "/user/logout" do
        session[:user_id] = nil
        { message: "Logout successfully" }.to_json
      end


      post "/add/pet" do
        user = User.find_by(id: session[:user_id])
        if user
          pet =
            Pet.create(
              name: params[:name],
              breed: params[:breed],
              age: params[:age],
              user_id: user.id,
            )
          if pet.valid?
            { message: "Pet added successfully" }.to_json
          else
            { error: "Failed to add pet" }.to_json
          end
        else
          { error: "You must be logged in to add a pet" }.to_json
        end
      end

      
      get "/pets" do
        pets = Pet.all
        pets.to_json
    end


    get "/pets/user" do
        user = User.find_by(id: session[:user_id])
        if user
          pets = user.pets
          pets.to_json
        else
          { error: "You must be logged in to view your pets" }.to_json
        end
      end


      get "/pets/search/name/:name" do
        pets = Pet.where("name LIKE ?", "%#{params[:name]}%")
        pets.to_json
      end


      get "/pets/search/breed/:breed" do
        pets = Pet.where("breed LIKE ?", "%#{params[:breed]}%")
        pets.to_json
      end


      put "/pets/update/:id" do
        pet = Pet.find(params[:id])
        if pet.user_id == session[:user_id]
          pet.update(
            name: params[:name],
            breed: params[:breed],
            age: params[:age],
            description: params[:description],
          )
          pet.to_json
        else
          { error: "You cannot update this pet" }.to_json
        end
      end


      delete "/pets/delete/:id" do
        pet = Pet.find(params[:id])
        if pet.user_id == session[:user_id]
          pet.destroy
          { message: "Pet Deleted " }.to_json
        else
          { error: "You cannot delete this pet" }.to_json
        end
      end
    end