module Asana
  class Client
    module Users
        def users
          response = connection.get "/api/1.0/users"
          response.body
        end

        def user(id)
          response = connection.get "/api/1.0/users/#{id}"
          response.body
        end
    end
  end
end