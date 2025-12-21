class Admin::QuotesController < ApplicationController
  def index
    # Start with all quotes, ordered by newest
    @quotes = Quote.all.order(created_at: :desc)
    
    # FILTER: If a lead_id is present in the URL, narrow down the list
    if params[:lead_id].present?
      @lead = Lead.find(params[:lead_id])
      @quotes = @quotes.where(lead_id: params[:lead_id])
      flash.now[:notice] = "Showing quotes for client: #{@lead.name}"
    end
  end

  def update_status
    @quote = Quote.find(params[:id])
    
    # This block now handles the database update AND the browser redirect safely
    if @quote.update(status: params[:status])
      # status: :see_other is REQUIRED for Turbo to reload the page
      redirect_to admin_quotes_path, notice: "Status updated to #{@quote.status}", status: :see_other
    else
      redirect_to admin_quotes_path, alert: "Update failed.", status: :see_other
    end
  end

  def edit
    @quote = Quote.find(params[:id])
  end
end