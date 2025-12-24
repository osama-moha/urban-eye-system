class QuotesController < ApplicationController

  # 1. The Form Page
  def new
    @quote = Quote.new
  end

  # 2. Process the Form
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
    
    @lead.save!

    # Create the Quote
    @quote = @lead.quotes.new(quote_params.except(:whatsapp_number, :email, :name, :location))

    # === THE FIX FOR "CANT BE BLANK" ERROR ===
    # If the form sent nothing (nil) for cameras, force it to 0
    @quote.camera_count = 0 if @quote.camera_count.nil?
    # =========================================

    # --- Only Calculate if Cameras Exist (> 0) ---
    if defined?(PriceCalculator)
      if @quote.camera_count.to_i > 0
        calculator = PriceCalculator.new(
          quote_params[:camera_count],
          quote_params[:outdoor_count],
          quote_params[:building_type],
          quote_params[:floors],
          quote_params[:recording_days],
          quote_params[:monitor],
          quote_params[:ups],
          quote_params[:subscription] 
        )
        result = calculator.calculate
        @quote.total_amount = result[:total]
      else
        # GUARD MODE: Price is 0 (Pending Survey)
        @quote.total_amount = 0
      end
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

  # 3. The Result Page (Kept the same)
  def show
    @quote = Quote.find(params[:id])
    
    @outdoor_count = @quote.outdoor_count.to_i 
    @indoor_count = @quote.camera_count.to_i - @outdoor_count

    if defined?(PriceCalculator)
      is_sub = @quote.respond_to?(:subscription) ? @quote.subscription : false

      # Only run detailed breakdown if it's a CCTV quote
      if @quote.camera_count.to_i > 0
        calculator = PriceCalculator.new(
          @quote.camera_count, @quote.outdoor_count, @quote.building_type,
          @quote.floors, @quote.recording_days, 
          @quote.monitor, 
          @quote.ups,
          is_sub 
        )
        result = calculator.calculate
        
        @details = result[:details]
        @min = result[:total]
        
        @hardware = result[:details][:hardware_kit]
        @labor = result[:details][:labor]
        @infrastructure = result[:details][:infrastructure]
        @hdd_name = result[:details][:hdd_size]
        @dvr_name = result[:details][:dvr_type]
      else
        # Guard Mode Defaults
        @min = 0
        @details = {}
      end
    end
  end

  private

  def quote_params
    params.require(:quote).permit(
      :camera_count, :outdoor_count, :building_type, :floors, 
      :timeline, :purpose, :recording_days, 
      :monitor, :ups, 
      :subscription,
      :name, :email, :whatsapp_number, :location
    )
  end
end