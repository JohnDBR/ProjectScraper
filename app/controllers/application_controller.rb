class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from Exceptions::CurrentUserNotFound, with: :if_user_not_found

  before_action :get_current_user

  protected
  def get_current_user
    authenticate_with_http_token do |key, options|
      token = Token.find_by(secret: key)
      @current_user = token.user if token
    end
    raise Exceptions::CurrentUserNotFound unless @current_user
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
