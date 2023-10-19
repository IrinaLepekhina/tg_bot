module Api
  module V1
    class WelcomeController < ApiController

      def index
        render plain: 'Welcome'
      end
    end
  end
end