# CORRECT: Inherits from the Admin Controller (Protected)
class Admin::LeadsController < Admin::ApplicationController
  
  def index
    @leads = Lead.all.order(created_at: :desc)
  end
  
end