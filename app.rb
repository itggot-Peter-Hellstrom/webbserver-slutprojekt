class App < Sinatra::Base
require 'sinatra'
require 'sqlite3'
		
	get('/') do
		tja
	end
		

end
