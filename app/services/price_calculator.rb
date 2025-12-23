class PriceCalculator
  # ==========================================
  # 1. YOUR BUYING COSTS (What YOU pay at the shop)
  # ==========================================
  COSTS = {
    camera_indoor: 1500,
    camera_outdoor: 2100,  # Slightly higher for outdoor
    
    # DVR Costs
    dvr_4ch: 4200,
    dvr_8ch: 6000,
    dvr_16ch: 11000,
    
    # HDD Costs
    hdd_500gb: 2500,
    hdd_1tb: 4200,
    hdd_2tb: 6500,
    hdd_4tb: 10500,

    # Accessories
    monitor: 3500,       # Your cost for a decent screen
    ups: 0,           # Your cost for a 650VA UPS
    
    # Infrastructure
    cable_per_m: 15,     # Your buying price per meter (approx)
    infra_kit: 500       # Boxes, tape, ties per camera
  }

  # ==========================================
  # 2. LABOR & SURCHARGES
  # ==========================================
  LABOR_PER_CAM = 1000
  BASE_TRANSPORT = 2500
  FLOOR_SURCHARGE = 500   # Per floor above ground
  COMMERCIAL_FEE = 3000   # Extra complexity for offices
  INDUSTRIAL_FEE = 5000   # Extra complexity for warehouses

  def initialize(total, outdoor, building_type, floors, days, monitor, ups)
    @total = total.to_i
    @outdoor = outdoor.to_i
    @indoor = @total - @outdoor
    @building_type = building_type 
    @floors = floors.to_i
    @days = days.to_i
    # Handle checkboxes (which might come in as "1", "true", or true)
    @monitor = [true, "true", "1", 1].include?(monitor)
    @ups = [true, "true", "1", 1].include?(ups)
  end

  def calculate
    # ------------------------------------------------
    # STEP A: CALCULATE RAW MATERIAL COST
    # ------------------------------------------------
    
    # 1. Cameras
    raw_cameras = (@indoor * COSTS[:camera_indoor]) + (@outdoor * COSTS[:camera_outdoor])

    # 2. Central Unit (DVR + HDD + PSU)
    # We use helper methods to pick the right size based on TOTAL cams and DAYS
    raw_central = get_dvr_cost(@total) + get_hdd_cost(@total, @days) + get_psu_cost(@total)

    # 3. Extras (Monitor + UPS)
    raw_extras = 0
    raw_extras += COSTS[:monitor] if @monitor
    raw_extras += COSTS[:ups] if @ups

    # 4. Infrastructure (Smart Calculation)
    # We estimate cable usage based on building type
    avg_cable_per_cam = case @building_type
                        when "Industrial / Warehouse" then 40 # Long runs
                        when "Commercial / Office" then 25
                        else 20 # Residential default
                        end
    
    cable_cost = (@total * avg_cable_per_cam * COSTS[:cable_per_m])
    baluns_cost = (@total * 350) # Video baluns / DC jacks
    infra_buffer = (@total * COSTS[:infra_kit]) # Junction boxes, tape, etc.

    raw_infra = cable_cost + baluns_cost + infra_buffer


    # ------------------------------------------------
    # STEP B: CALCULATE LABOR COST
    # ------------------------------------------------
    raw_labor = BASE_TRANSPORT + (@total * LABOR_PER_CAM)

    # FIX: Floor Logic (Charge only for floors ABOVE ground)
    if @floors > 1
      raw_labor += (@floors - 1) * FLOOR_SURCHARGE
    end

    # Surcharges for building type
    case @building_type
    when "Commercial / Office"
      raw_labor += COMMERCIAL_FEE
    when "Industrial / Warehouse"
      raw_labor += INDUSTRIAL_FEE
    end


    # ------------------------------------------------
    # STEP C: APPLY PROFIT MARGIN & TOTAL
    # ------------------------------------------------
    
    # Dynamic Margin: Lower % for bulk jobs, Higher % for small jobs
    margin_percent = @total > 8 ? 0.25 : 0.30 

    # Calculate Selling Prices
    sell_hardware = (raw_cameras + raw_central + raw_extras) * (1 + margin_percent)
    sell_infra    = raw_infra * (1 + margin_percent)
    sell_labor    = raw_labor * (1 + margin_percent)

    # Sum it up
    grand_total = sell_hardware + sell_infra + sell_labor

    # ------------------------------------------------
    # STEP D: MINIMUM PRICE SAFETY NET
    # ------------------------------------------------
    # If it's a new system (has DVR), never go below 15k
    min_price = 15000
    grand_total = [grand_total, min_price].max

    # Return the hash for your View
    {
      details: {
        hardware_kit: round_price(sell_hardware),
        infrastructure: round_price(sell_infra),
        labor: round_price(sell_labor),
        
        # Details for the quote text
        dvr_type: get_dvr_name(@total),
        hdd_size: get_hdd_name(@total, @days),
        monitor_included: @monitor ? "Yes" : "No",
        ups_included: @ups ? "Yes" : "No"
      },
      total: round_price(grand_total)
    }
  end

  private

  # Helper to round to nearest 100 (e.g. 14230 -> 14300)
  def round_price(price)
    (price / 100.0).ceil * 100
  end

  def get_dvr_cost(count)
    if count <= 4 then COSTS[:dvr_4ch]
    elsif count <= 8 then COSTS[:dvr_8ch]
    else COSTS[:dvr_16ch] end
  end

  def get_dvr_name(count)
    if count <= 4 then "4-Channel DVR"
    elsif count <= 8 then "8-Channel DVR"
    else "16-Channel DVR" end
  end

  # UPDATED: HDD Logic now respects 'days'
  def get_hdd_cost(count, days)
    # Simple logic: If many cameras OR many days, bump up the size
    if (count <= 4 && days <= 7)
      COSTS[:hdd_500gb]
    elsif (count <= 4 && days > 7) || (count <= 8 && days <= 7)
      COSTS[:hdd_1tb]
    elsif (count <= 8 && days > 7) || (count <= 16 && days <= 7)
      COSTS[:hdd_2tb]
    else
      COSTS[:hdd_4tb]
    end
  end

  def get_hdd_name(count, days)
    if (count <= 4 && days <= 7)
      "500GB Surveillance HDD"
    elsif (count <= 4 && days > 7) || (count <= 8 && days <= 7)
      "1TB Surveillance HDD"
    elsif (count <= 8 && days > 7) || (count <= 16 && days <= 7)
      "2TB Surveillance HDD"
    else
      "4TB Surveillance HDD"
    end
  end

  def get_psu_cost(count)
    if count <= 4 then 1000
    elsif count <= 8 then 2000
    else 3500 end
  end
end