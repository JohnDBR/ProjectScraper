class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from Exceptions::CurrentUserNotFound, with: :if_user_not_found
  rescue_from Exceptions::TokenExpired, with: :if_token_expired

  before_action :get_current_user

  #{Rails.application.config.action_controller.default_url_options[:host]}
  def self.default_url_options
    if Rails.env.production?
      {
        env: "prod",
        host: "api.imaginatuciuda.org", #"prod.jfarellano.xyz", 
        protocol: "https",
        front_url: "https://www.imaginatuciuda.org", #"https://ciuda.jfarellano.xyz",
        admin_url: "https://admin.imaginatuciuda.org" #"https://admin.jfarellano.xyz"
      }
    elsif Rails.env.test?  
      {
        env: "test",
        host: "test-api.imaginatuciuda.org", #"test.jfarellano.xyz", 
        protocol: "https",
        front_url: "https://test.imaginatuciuda.org", #"https://ciuda-test.jfarellano.xyz",
        admin_url: "https://test-admin.imaginatuciuda.org" #"https://admin-test.jfarellano.xyz"
      }
    else 
      {
        env: "dev",
        host: "dev-api.imaginatuciuda.org", #"dev.jfarellano.xyz", 
        protocol: "https",
        front_url: "https://dev.imaginatuciuda.org", #NOT WORKING... #"https://ciuda-dev.jfarellano.xyz",
        admin_url: "https://dev-admin.imaginatuciuda.org" #NOT WORKING... #"https://admin-dev.jfarellano.xyz"
      }
    end
  end

  protected
  def get_current_user
    set_user_by_token
    raise Exceptions::CurrentUserNotFound unless @current_user
  end

  def set_user_by_token
    @current_user = nil
    authenticate_with_http_token do |key, options|
      @token = Token.find_by(secret: key)
      expired = @token ? @token.expire_at.past? : false
      if expired
        @token.destroy 
        raise Exceptions::TokenExpired
      end
      @current_user = @token.user if @token
    end
    # request.headers.each do |key, options|
    #   pp key
    #   pp options
    # end
  end

  def is_current_user_admin
    permissions_error unless @current_user.role.eql? "admin" 
  end

  def is_current_user_normal
    permissions_error unless @current_user.role.eql? "normal"
  end

  def is_current_user_member(group_id)
    m = Member.where(group_id:group_id.to_i, user_id:@current_user.id)
    return false if m.empty?
    return m.first
  end

  def is_group_admin(group_id)
    m = Member.where(group_id:group_id, user_id:@current_user.id)
    return false if m.empty?
    return m.first.admin
  end

  def permissions_error
    render json: {authorization: 'you dont have permissions'}, status: :permissions_error
  end

  def uninorte_authentication_error
    render json: {authorization: 'uninorte invalid credentials'}, status: :unprocessable_entity
  end

  def render_ok(obj)
    render json: obj, status: :ok
  end

  def if_save_succeeds(obj, options={})
    if obj.save
      self.send(options[:call_after_save]) if options[:call_after_save]
      yield(obj) if block_given?
    else
      self.send(options[:call_if_error]) if options[:call_if_error]
      render json: {errors:obj.errors.messages}, status: options[:error_status] || :unprocessable_entity
    end
  end

  def save_and_render(obj, options={})
    if_save_succeeds(obj, options) do |object|
      render json: options[:call_on_render] ? self.send(options[:call_on_render]) : object, status: options[:succeed_status] || :ok
      self.send(options[:call_after_render]) if options[:call_after_render]
    end
  end

  def record_not_found(exception)
    render json: {record_not_found:exception.message}, status: :unprocessable_entity
  end

  def if_user_not_found
    render json: {authentication: 'user not found'}, status: :unprocessable_entity
  end

end
