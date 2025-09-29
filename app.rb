require 'sinatra/base'
require 'sinatra/flash'
require './lib/wordguesser_game.rb'

class WordGuesserApp < Sinatra::Base
  register Sinatra::Flash

  disable :protection
  disable :show_exceptions
  set :protection, false
  
  configure do
    enable :sessions
    set :session_store, Rack::Session::Cookie
    set :sessions, key: 'rack.session',
                   domain: nil,
                   path: '/',
                   expire_after: 2592000,
                   secret: ENV.fetch('SESSION_SECRET') { 
                     require 'securerandom'
                     SecureRandom.hex(64) 
                   }
    
   
    set :bind, '0.0.0.0'
    
    
    set :allowed_origins, '*'
  end
  
  
  def self.call(env)
    env['HTTP_HOST'] = env['SERVER_NAME'] if env['HTTP_HOST'].nil?
    super(env)
  end
  
  before do
    @game = session[:game] || WordGuesserGame.new('')
  end
  
  after do
    session[:game] = @game
  end
  
  get '/' do
    redirect '/new'
  end
  
  get '/new' do
    erb :new
  end
  
  post '/create' do
    word = params[:word] || WordGuesserGame.get_random_word
    @game = WordGuesserGame.new(word)
    redirect '/show'
  end
  
  post '/guess' do
    letter = params[:guess].to_s[0]
    
    begin
      if @game.guess(letter)
        redirect '/show'
      else
        flash[:message] = "You have already used that letter."
        redirect '/show'
      end
    rescue ArgumentError
      flash[:message] = "Invalid guess."
      redirect '/show'
    end
  end
  
  get '/show' do
    status = @game.check_win_or_lose
    
    if status == :win
      redirect '/win'
    elsif status == :lose
      redirect '/lose'
    else
      erb :show
    end
  end
  
  get '/win' do
    if @game.check_win_or_lose == :win
      erb :win
    else
      flash[:message] = "You must finish the game first!"
      redirect '/show'
    end
  end
  
  get '/lose' do
    if @game.check_win_or_lose == :lose
      erb :lose
    else
      flash[:message] = "You must finish the game first"
      redirect '/show'
    end
  end
end
