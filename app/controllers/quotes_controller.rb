class QuotesController < ApplicationController

  # 1. The Form Page
  def new
    @quote = Quote.new
  end

  # 2. Process the Form
  def create
    # Capture inputs
    phone = quote_params[:whatsapp_number]
    email = quote_params[:email]

    # Find or Create the Lead
    @lead = Lead.find_or_initialize_by(phone: phone)
    @lead.email = email if email.present?
    @lead.name = quote_params[:name] if quote_params[:name].present?
    @lead.location = quote_params[:location] if quote_params[:location].present?
    
    if quote_params[:building_type].present?
      @lead.property_type = quote_params[:building_type] 
    end
    
    @lead.save!

    # Create the Quote attached to the Lead
    # We exclude contact info since that went to the Lead model
    @quote = @lead.quotes.new(quote_params.except(:whatsapp_number, :email, :name, :location))

    # --- PRICE CALCULATION START ---
    if defined?(PriceCalculator)
      # We use the params DIRECTLY here to ensure we capture the checkbox state accurately
      # (Checkboxes sometimes send "0" or "1", handling it here is safer)
      calculator = PriceCalculator.new(
        quote_params[:camera_count],
        quote_params[:outdoor_count],
        quote_params[:building_type],
        quote_params[:floors],
        quote_params[:recording_days],
        quote_params[:monitor], # Pass the raw param (likely "0" or "1")
        quote_params[:ups]      # Pass the raw param
      )
      
      result = calculator.calculate
      @quote.total_amount = result[:total]
    else
      @quote.total_amount = 0
    end
    # --- PRICE CALCULATION END ---

    if @quote.save
      # Send Email (Optional)
      # QuoteMailer.with(quote: @quote).new_quote_alert.deliver_later
      
      # Redirect to the Result page
      redirect_to @quote, notice: 'Quote created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # 3. The Result Page
  def show
    @quote = Quote.find(params[:id])

    # Calculate Indoor/Outdoor counts for display
    @outdoor_count = @quote.outdoor_count.to_i 
    @indoor_count = @quote.camera_count.to_i - @outdoor_count

    # Re-calculate details for display
    if defined?(PriceCalculator)
      calculator = PriceCalculator.new(
        @quote.camera_count, 
        @quote.outdoor_count, 
        @quote.building_type,
        @quote.floors, 
        @quote.recording_days, 
        @quote.monitor, # This uses the TRUE/FALSE saved in the DB
        @quote.ups
      )
      result = calculator.calculate
      
      # Set variables for the view
      @details = result[:details]
      @min = result[:total]
      
      # Extract details safely
      @hardware = result[:details][:hardware_kit]
      @labor = result[:details][:labor]
      @infrastructure = result[:details][:infrastructure]
      @hdd_name = result[:details][:hdd_size]
      @dvr_name = result[:details][:dvr_type]
    end
  end

  # --- PRIVATE SECTION ---
  private

  def quote_params
    params.require(:quote).permit(
      :camera_count, 
      :outdoor_count, 
      :building_type, 
      :floors, 
      :timeline, 
      :purpose, 
      :recording_days, 
      :monitor, 
      :ups, 
      :name, 
      :email, 
      :whatsapp_number,
      :location
    )
  end
end