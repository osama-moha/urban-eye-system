module Admin
  class ApplicationController < Administrate::ApplicationController
    # UPDATE THIS LINE: Use the new model name
    before_action :authenticate_system_admin!

    # UPDATE THIS LINE: Logic for the logout button
    def after_sign_out_path_for(resource_or_scope)
      new_system_admin_session_path
    end
  end
end