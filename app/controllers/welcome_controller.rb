class WelcomeController < ActionController::Base

    def welcome
        url_helper = ApplicationController.default_url_options
        render "#{url_helper[:env]}"
    end

    def dev
        # render plain: "dev"
        # render "dev"
    end

    def prod
        # render plain: "prod"
        # render "prod"
    end

    def test
        # render plain: "test"
        # render "test"
    end
    
end
  