require './app'


class BypassHostCheck
  def initialize(app)
    @app = app
  end
  
  def call(env)
    # Allow any host
    env.delete('HTTP_X_FORWARDED_HOST')
    @app.call(env)
  end
end

use BypassHostCheck

run WordGuesserApp
