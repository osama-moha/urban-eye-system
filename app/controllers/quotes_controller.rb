class QuotesController < ApplicationController
  # 1. The Form Page (This was missing!)
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
    @lead.name = quote_params[:name] if quote_params[:name].present?         # <--- Added
    @lead.location = quote_params[:location] if quote_params[:location].present?

    if quote_params[:building_type].present?
  @lead.property_type = quote_params[:building_type] 
end
    @lead.save!

    # Create the Quote
    @quote = @lead.quotes.new(quote_params.except(:whatsapp_number, :email, :name, :location))

    # Calculate Price
    if defined?(PriceCalculator)
      calculator = PriceCalculator.new(
        @quote.camera_count, @quote.outdoor_count, @quote.building_type,
        @quote.floors, @quote.recording_days, @quote.monitor, @quote.ups
      )
      result = calculator.calculate
      @quote.total_amount = result[:total]
    else
      # Fallback if calculator creates an error
      @quote.total_amount = 0
    end

    if @quote.save
      # Send Email in background
      QuoteMailer.with(quote: @quote).new_quote_alert.deliver_later
      
      # Redirect to the Result page
      redirect_to @quote, notice: 'Quote created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # 3. The Result Page
  def show
    @quote = Quote.find(params[:id])

    @quote = Quote.find(params[:id])
  
  # --- FIX: Use the correct column name 'outdoor_count' ---
  outdoor = @quote.outdoor_count.to_i 
  @outdoor_count = outdoor
  
  # Calculate indoor automatically (Total - Outdoor)
  @indoor_count = @quote.camera_count.to_i - outdoor

    # Re-calculate details for display
    if defined?(PriceCalculator)
      calculator = PriceCalculator.new(
        @quote.camera_count, @quote.outdoor_count, @quote.building_type,
        @quote.floors, @quote.recording_days, @quote.monitor, @quote.ups
      )
      result = calculator.calculate
      
      # Set variables for the view
      @details = result[:details]
      @min = result[:total]
      @hardware = result[:details][:hardware_kit]
      @labor = result[:details][:labor]
      @infrastructure = result[:details][:infrastructure]
      @indoor_count = result[:details][:indoor_count]
      @outdoor_count = result[:details][:outdoor_count]
      @hdd_name = result[:details][:hdd_size]
      @dvr_name = result[:details][:dvr_type]
    end
  end

  # --- PRIVATE SECTION (Must be at the bottom) ---
  private

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
      :location  # <--- ADD THIS LINE HERE
    )
  end
end