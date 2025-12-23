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
    
    # --- FIX: Set "Interest" correctly for Subscriptions ---
    if quote_params[:subscription] == "1"
      @lead.property_type = "Starter Shield Package"
    elsif quote_params[:building_type].present?
      @lead.property_type = quote_params[:building_type] 
    end
    # -------------------------------------------------------
    
    @lead.save!

    # Create the Quote
    @quote = @lead.quotes.new(quote_params.except(:whatsapp_number, :email, :name, :location))

    if defined?(PriceCalculator)
      # PASS PARAMS DIRECTLY + NEW SUBSCRIPTION FLAG
      calculator = PriceCalculator.new(
        quote_params[:camera_count],
        quote_params[:outdoor_count],
        quote_params[:building_type],
        quote_params[:floors],
        quote_params[:recording_days],
        quote_params[:monitor],
        quote_params[:ups],
        quote_params[:subscription] # <--- NEW: Pass the checkbox value!
      )
      
      result = calculator.calculate
      @quote.total_amount = result[:total]
      
      # Save the subscription choice to the DB (requires Step 1 migration)
      @quote.subscription = quote_params[:subscription]
    else
      @quote.total_amount = 0
    end

    if @quote.save
      redirect_to @quote, notice: 'Quote created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # 3. The Result Page
  def show
    @quote = Quote.find(params[:id])
    
    @outdoor_count = @quote.outdoor_count.to_i 
    @indoor_count = @quote.camera_count.to_i - @outdoor_count

    if defined?(PriceCalculator)
      # We check if the saved quote has 'subscription' set to true
      is_sub = @quote.respond_to?(:subscription) ? @quote.subscription : false

      calculator = PriceCalculator.new(
        @quote.camera_count, @quote.outdoor_count, @quote.building_type,
        @quote.floors, @quote.recording_days, 
        @quote.monitor, 
        @quote.ups,
        is_sub # <--- NEW: Tell calculator this is a subscription quote
      )
      result = calculator.calculate
      
      @details = result[:details]
      @min = result[:total]
      
      # Standard variables
      @hardware = result[:details][:hardware_kit]
      @labor = result[:details][:labor]
      @infrastructure = result[:details][:infrastructure]
      @hdd_name = result[:details][:hdd_size]
      @dvr_name = result[:details][:dvr_type]
    end
  end

  private

  def quote_params
    params.require(:quote).permit(
      :camera_count, :outdoor_count, :building_type, :floors, 
      :timeline, :purpose, :recording_days, 
      :monitor, :ups, 
      :subscription, # <--- NEW: Allow this parameter!
      :name, :email, :whatsapp_number, :location
    )
  end
end