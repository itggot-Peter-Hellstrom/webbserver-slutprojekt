class App < Sinatra::Base
	require 'sinatra'
	require 'sqlite3'
	enable :sessions
		get('/') do
			slim(:index, locals:{ greeting: "Hello from index!" })
		end
		get('/register') do
			slim(:register)
		end	  
		get('/error') do
			slim(:error)
		end
		def set_error(error_message)
			session[:error] = error_message
		end
	
		def get_error()
			error = session[:error]
			session[:error] = nil
			return error
		end

		get('/notes') do
			db = SQLite3::Database.new('db/db.db')
			user = db.execute("SELECT * FROM users WHERE id=?", session[:user_id])
			p user
			slim(:notes, locals:{session:session, user:user})
		end
		
		post('/register') do
			db = SQLite3::Database.new('db/db.db')
			db.results_as_hash = true
			
			username = params["username"]
			password = params["password"]
			password_confirmation = params["password2"]
			
			result = db.execute("SELECT id FROM users WHERE username=?", [username])
			
			if result.empty?
				if password == password_confirmation
					password_digest = BCrypt::Password.create(password)
					
					db.execute("INSERT INTO users(username, password_digest) VALUES (?,?)", [username, password_digest])
					redirect('/')
				else
					set_error("Passwords don't match")
					redirect('/error')
				end
			else
				set_error("Username already exists")
				redirect('/error')
			end
			
		end
	
		post('/login') do
			db = SQLite3::Database.new('db/db.db')
			db.results_as_hash = true
			username = params["username"]
			password = params["password"]
			
			result = db.execute("SELECT id, password_digest FROM users WHERE username=?", [username])
	
			if result.empty?
				set_error("Invalid Credentials")
				redirect('/error')
			end
	
			user_id = result.first["id"]
			password_digest = result.first["password_digest"]
			if BCrypt::Password.new(password_digest) == password
				session[:user_id] = user_id
				redirect('/notes')
			else
				set_error("Invalid Credentials")
				redirect('/error')
			end
		end

		
	end