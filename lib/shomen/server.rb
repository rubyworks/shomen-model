require 'sinatra'

set :run, true
set :static, true
set :public, Dir.pwd

get '/' do
  redirect 'index.html'
end

