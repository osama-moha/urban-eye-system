class PriceCalculator
  # ==========================================
  # 1. YOUR REAL BUYING COSTS (What YOU pay at the shop)
  # ==========================================
  # Hardware Costs
  COST_CAM_INDOOR  = 1500
  COST_CAM_OUTDOOR = 2000
  
  # DVR Costs
  COST_DVR_4CH  = 4200
  COST_DVR_8CH  = 6000
  COST_DVR_16CH = 11000
  
  # Storage Costs
  COST_HDD_500GB = 2500
  COST_HDD_1TB   = 4200
  COST_HDD_2TB   = 6500
  COST_HDD_4TB   = 10500

  # Power & Accessories
  COST_PSU_SMALL = 1000
  COST_PSU_MED   = 2500
  COST_PSU_LARGE = 5000

  # Extras (Buying Price)
  COST_MONITOR = 3500  # A standard 19" monitor costs you ~3.5k
  COST_UPS     = 5500  # A 650VA UPS costs you ~5.5k

  # Infrastructure (Cables, Clips, Trunking)
  COST_INFRA_PER_CAM = 800 
  COST_INFRA_BUFFER  = 2000 # Only for big jobs

  # Labor (What you pay the technician)
  PAY_TECH_PER_CAM = 1000
  PAY_TRANSPORT    = 2000 

  def initialize(total, outdoor, building_type, floors, days, monitor, ups)
    @total = total.to_i
    @outdoor = outdoor.to_i
    @indoor = @total - @outdoor
    @building_type = building_type 
    @floors = floors.to_i
    @days = days.to_i
    
    # Ensure these are treated as Booleans (True/False)
    @monitor = [true, "true", "1", 1].include?(monitor)
    @ups = [true, "true", "1", 1].include?(ups)
  end

  def calculate
    # ------------------------------------------------
    # STEP 1: CALCULATE RAW COST (Internal)
    # ------------------------------------------------
    
    # A. Hardware
    raw_cams = (@indoor * COST_CAM_INDOOR) + (@outdoor * COST_CAM_OUTDOOR)
    raw_central = get_dvr_cost(@total) + get_hdd_cost(@total, @days) + get_psu_cost(@total)
    
    raw_hardware = raw_cams + raw_central

    # B. Extras (Monitor/UPS)
    raw_extras = 0
    raw_extras += COST_MONITOR if @monitor
    raw_extras += COST_UPS if @ups

    # C. Infrastructure
    raw_infra = @total * COST_INFRA_PER_CAM
    raw_infra += COST_INFRA_BUFFER if @total > 8

    # D. Labor
    # For small jobs (<=4), we assume easier transport
    transport_cost = @total <= 4 ? 1500 : PAY_TRANSPORT
    
    raw_labor = (@total * PAY_TECH_PER_CAM) + transport_cost
    
    # Add floor surcharge only if strictly necessary
    if @floors > 1
      raw_labor += (@floors - 1) * 500
    end


    # ------------------------------------------------
    # STEP 2: APPLY MARGIN (The Pricing Logic)
    # ------------------------------------------------
    
    # LOGIC: 
    # 1-4 Cams: 20% Margin (To win home jobs)
    # 5-8 Cams: 30% Margin (Standard job)
    # 9+  Cams: 35% Margin (Corporate job complexity)
    
    if @total <= 4
      margin_percent = 0.20
    elsif @total <= 8
      margin_percent = 0.30
    else
      margin_percent = 0.35
    end

    # Apply Markup
    sell_hardware = (raw_hardware * (1 + margin_percent))
    sell_infra    = (raw_infra * (1 + margin_percent))
    sell_labor    = (raw_labor * (1 + margin_percent))

    # Extras get a fixed, lower markup (don't overcharge for monitors)
    sell_extras   = (raw_extras * 1.20) 

    # Rounding to clean numbers
    sell_hardware = round_up(sell_hardware + sell_extras)
    sell_infra    = round_up(sell_infra)
    sell_labor    = round_up(sell_labor)

    grand_total = sell_hardware + sell_infra + sell_labor

    # Minimum Price Safety Net (Never go below 25k for a full kit)
    if grand_total < 25000
       grand_total = 25000
    end

    {
      details: {
        hardware_kit: sell_hardware,
        infrastructure: sell_infra,
        labor: sell_labor,
        dvr_type: get_dvr_name(@total),
        hdd_size: get_hdd_name(@total, @days)
      },
      total: grand_total
    }
  end

  private

  def round_up(num)
    (num / 100.0).ceil * 100
  end

  def get_dvr_cost(count)
    if count <= 4 then COST_DVR_4CH
    elsif count <= 8 then COST_DVR_8CH
    else COST_DVR_16CH end
  end

  def get_hdd_cost(count, days)
    # Smart logic: 4 cams + 7 days = 500GB (Save money)
    # 4 cams + 14 days = 1TB
    if count <= 4 && days <= 7
      COST_HDD_500GB
    elsif count <= 8 && days <= 7
      COST_HDD_1TB
    elsif count <= 16
      COST_HDD_2TB
    else
      COST_HDD_4TB
    end
  end
  
  def get_hdd_name(count, days)
    if count <= 4 && days <= 7
      "500GB HDD"
    elsif count <= 8 && days <= 7
      "1TB HDD"
    else
      "2TB/4TB HDD"
    end
  end

  def get_psu_cost(count)
    if count <= 4 then COST_PSU_SMALL
    elsif count <= 8 then COST_PSU_MED
    else COST_PSU_LARGE end
  end

  def get_dvr_name(count)
    if count <= 4 then "4-Channel DVR"
    elsif count <= 8 then "8-Channel DVR"
    else "16-Channel DVR" end
  end
end