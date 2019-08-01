class SessionsController < ApplicationController
  skip_before_action :get_current_user 
  before_action :initialize_authenticate_scraper, only: [:create]
  # before_action :initialize_pomelo_scraper, only: [:create]

  def create    
    if @sl.login_pomelo?(params[:user], params[:password])
      if user = User.find_by(username: params[:user].downcase)
        token = Token.create(user:user) 
        render json: token, status: :created
      else
        user = User.new(username:(params[:user]) #role:0,
        if user.save
          token = Token.create(user:user) 
          render json: token, status: :created 
        else
          render json: {errors:user.errors.messages}, status: :unprocessable_entity
        end
      end
    else
      uninorte_authentication_error
    end
  end

  def destroy 
    token = nil
    authenticate_with_http_token do |key, options|
      token = Token.find_by(secret: key)
      if token
        render_ok token.destroy 
      end  
    end   
    render json: {errors: "invalid token"}, status: :bad_request unless token
  end

  def guest_create #Auth
    auth = Authentication.new
    auth.start_session({email:params[:email], username:params[:username], password:params[:password]})
    if auth.allowed?
      link = Link.where(secret:params[:link]).first
      member = Member.where(group_id:link.group_id, user_id:auth.user.id).first
      if member
        render json: {authorization: "already in", token: auth.token}, status: :unprocessable_entity        
      else
        member = Member.create(alias:params[:alias], group_id:link.group_id, user_id:auth.user.id, admin:false)
        link = link.destroy
        render json: {token:auth.token, link:link, member:member}, status: :created
      end  
    else
      render json: auth.errors, status: :unauthorized 
    end
  end

  private
  def session_params
    params.permit(:email, :username, :password)
  end

  def user_params
    params.permit(
      #:email,
      #:password,
      :username
    )
  end
end
