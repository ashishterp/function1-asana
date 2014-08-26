module Asana
  class Client
    module Tasks
      def my_tasks
        response = connection.get "/api/1.0/workspaces/10129623097306/tasks" , {assignee: @current_user["data"]["id"]}
        response.body
      end
    end
  end
end