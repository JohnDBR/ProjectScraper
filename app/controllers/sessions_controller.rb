class SessionsController < ApplicationController
  skip_before_action :get_current_user 
  before_action :initialize_authenticate_scraper, only: [:create]
  # before_action :initialize_pomelo_scraper, only: [:create]

  def create    
    if @sl.login_pomelo?(params[:username], params[:password])
      if user = User.find_by(username: params[:username].downcase)
        token = Token.create(user:user) 
        render json: token, status: :created
      else
        user = User.new(username:params[:username]) #role:0,
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

  #This method does exactly the same as open#links but you can use an alias here
  def guest_create #This method is not going to be used due to Unimatrix requirements! ...
    #Authentication deprecated! The service is no longer supported
    auth = Authentication.new
    auth.start_session({email:params[:email], username:params[:username], password:params[:password]})
    if auth.allowed?
      link = Link.where(secret:params[:link]).first
      member = Member.where(group_id:link.group_id, user_id:auth.user.id).first
      if member
        render json: {authorization: "already in", token: auth.token}, status: :unprocessable_entity        
      else
        member_alias = ""
        member_alias = params[:alias] if params[:alias]
        member = Member.create(alias:member_alias, group_id:link.group_id, user_id:auth.user.id, admin:false)
        link = link.destroy
        render json: {token:auth.token, link:link, member:member}, status: :created
      end  
    else
      render json: auth.errors, status: :unauthorized 
    end
  end

  private
  def initialize_authenticate_scraper
    @sl = ScrapingAuthenticate.new
  end

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
