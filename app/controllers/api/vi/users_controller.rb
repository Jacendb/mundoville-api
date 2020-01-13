class Api::V1::UsersController < ApplicationController
    skip_before_action :authorized, only: [:create, :index, :show], raise: false 
    # raise: false has to be added to this since recently to prevent error

    def index
        @users = User.all
        render json: @users, :except => [:password_digest], 
        # :include => [:username, :email, :bio, :avatar]
        :include => [:username, :user_type, :email, :bio, :avatar]
    end

    def show
      @user = User.find_by(id: params['id'])
      render json: @user, :except => [:password_digest]
    end
 
    def profile
        render json: { user: current_user }, :except => [:password_digest], 
        :include => [:username, :email, user_type, :bio, :avatar]
    end
  
    def create
      @user = User.create(user_params)
      if @user.valid?
        @token = encode_token({ user_id: @user.id })
        # render json: { user: @user, jwt: @token }, status: :created
        render json: { user: UserSerializer.new(@user), jwt: @token }, status: :created
      else
        render json: { error: 'failed to create user' }, status: :not_acceptable
      end
    end

    def update
        user = User.find_by(id: params['id'])
        if user.update(user_params)
            render json: { message: 'user successfully updated' }
        else
            render json: { error: 'could not update user'}, status: :not_acceptable
        end
    end

    def destroy
        user = User.find_by(id: params['id'])
        if user.destroy
            render json: { message: 'User successfully destroyed' }
        else
            render json: { message: 'Could not delete user. Please try again.'}
        end
    end
  
    private
  
    def user_params
      params.require(:user).permit(:username, :email, :user_type, :password, :bio, :avatar)
    end
    
end
