class QuotesController < ApplicationController
  def new
    @quote = Quote.new
  end

  def create
    @lead = Lead.find_or_initialize_by(phone: quote_params[:whatsapp_number])
    @lead.email = quote_params[:email] if quote_params[:email].present?
    @lead.name = quote_params[:name] if quote_params[:name].present?
    @lead.location = quote_params[:location] if quote_params[:location].present?
    @lead.save!

    @quote = @lead.quotes.new(quote_params.except(:whatsapp_number, :email, :name, :location))

    if defined?(PriceCalculator)
      # PASS PARAMS DIRECTLY to ensure checkboxes work
      calculator = PriceCalculator.new(
        quote_params[:camera_count],
        quote_params[:outdoor_count],
        quote_params[:building_type],
        quote_params[:floors],
        quote_params[:recording_days],
        quote_params[:monitor], # <--- Crucial fix
        quote_params[:ups]      # <--- Crucial fix
      )
      result = calculator.calculate
      @quote.total_amount = result[:total]
    end

    if @quote.save
      redirect_to @quote, notice: 'Quote created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @quote = Quote.find(params[:id])
    @outdoor_count = @quote.outdoor_count.to_i 
    @indoor_count = @quote.camera_count.to_i - @outdoor_count

    if defined?(PriceCalculator)
      calculator = PriceCalculator.new(
        @quote.camera_count, @quote.outdoor_count, @quote.building_type,
        @quote.floors, @quote.recording_days, 
        @quote.monitor, # Uses saved DB value
        @quote.ups
      )
      result = calculator.calculate
      @details = result[:details]
    end
  end

  private

  def quote_params
    params.require(:quote).permit(
      :camera_count, :outdoor_count, :building_type, :floors, 
      :timeline, :purpose, :recording_days, 
      :monitor, :ups, # Ensure these are permitted
      :name, :email, :whatsapp_number, :location
    )
  end
end