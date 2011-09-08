require 'sinatra'

set :run, true
set :static, true
set :public, ARGV[1] || Dir.pwd

get '/' do
  redirect 'index.html'
end

