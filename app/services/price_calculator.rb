class PriceCalculator
  # --- 1. HARDWARE PRICES (Nairobi Market Rates) ---
  DVR_4_CH = 4500
  DVR_8_CH = 7500   
  DVR_16_CH = 10000 

  HDD_500GB = 3000  
  HDD_1TB = 4500
  HDD_2TB = 6000
  HDD_4TB = 17500

  PSU_SMALL = 1500  
  PSU_MED   = 3500  
  PSU_LARGE = 6000  

  # Monitor & UPS Costs (Your Buying Price)
  MONITOR_COST = 3500 # Approx cost for 19-inch
  UPS_COST = 5500     # Approx cost for 650VA

  # --- 2. INFRASTRUCTURE PRICES ---
  CABLE_BOX_PRICE = 4500    
  CABLE_PER_METER = 40      
  VIDEO_BALUN_PAIR = 350    
  INFRA_KIT_PER_CAM = 400  

  # --- 3. LABOR PRICES ---
  BASE_LABOR_FEE = 2800      
  LABOR_PER_CAMERA = 1700
  
  COMMERCIAL_SURCHARGE = 2500
  INDUSTRIAL_SURCHARGE = 5000
  FLOOR_TAX = 500

  def initialize(total, outdoor, building_type, floors, days, monitor, ups)
    @total = total.to_i
    @outdoor = outdoor.to_i
    @indoor = @total - @outdoor
    @building_type = building_type 
    @floors = floors.to_i
    @days = days.to_i
    # Handle checkboxes (true/false or "1"/"0")
    @monitor = [true, "true", "1", 1].include?(monitor)
    @ups = [true, "true", "1", 1].include?(ups)
  end

  def calculate
    # ==========================================
    # STEP 1: CALCULATE YOUR "BUYING PRICE" (COSTS)
    # ==========================================
    
    # 1. Hardware Costs
    cost_camera_indoor  = 1500
    cost_camera_outdoor = 2000
    
    # Core Hardware (Cams + DVR + HDD + PSU)
    raw_cost_cameras = (@indoor * cost_camera_indoor) + (@outdoor * cost_camera_outdoor)
    raw_cost_central = get_dvr_cost(@total) + get_hdd_cost(@total) + get_psu_cost(@total)

    # Extras (Monitor + UPS)
    raw_cost_extras = 0
    raw_cost_extras += MONITOR_COST if @monitor
    raw_cost_extras += UPS_COST if @ups

    # 2. Infrastructure Costs
    cost_infra_per_cam = 900 
    raw_cost_infra = @total * cost_infra_per_cam
    
    if @total > 8
      raw_cost_infra += 2000 
    end

    # 3. Labor Costs
    tech_rate_per_cam = 1000
    tech_floor_fee = (@floors > 1) ? (@floors * 500) : 0
    tech_base_fee = 2000
   
    raw_cost_labor = (@total * tech_rate_per_cam) + tech_floor_fee + tech_base_fee

    case @building_type
    when "Commercial / Office"
      raw_cost_labor += COMMERCIAL_SURCHARGE
    when "Industrial / Warehouse"
      raw_cost_labor += INDUSTRIAL_SURCHARGE
    end

    if @floors > 1
      raw_cost_labor += (@floors * FLOOR_TAX)
    end
  

    # ==========================================
    # STEP 2: APPLY YOUR PROFIT MARGIN
    # ==========================================
    # 15% for small jobs, 30% for big jobs (Your preferred logic)
    markup_percent = if @total <= 8
                        0.25 # Slight bump to 25% for small jobs to be safe
                      else
                        0.30
                      end

    # Apply Markup
    # A. CORE HARDWARE: Gets full markup (Warranty Risk)
    sell_core_hardware = (raw_cost_cameras + raw_cost_central).to_f * (1 + markup_percent)

    # B. EXTRAS: Gets LOW markup (Box Moving - 20%)
    # This fixes the "Too Expensive" problem for Monitors/UPS
    sell_extras = raw_cost_extras.to_f * 1.20 

    sell_hardware = sell_core_hardware + sell_extras
    
    sell_infra    = raw_cost_infra.to_f * (1 + markup_percent)
    sell_labor    = raw_cost_labor.to_f * (1 + markup_percent)

    # Rounding
    sell_hardware = sell_hardware.ceil(-2)
    sell_infra    = sell_infra.ceil(-2)
    sell_labor    = sell_labor.ceil(-2)
    
    grand_total = sell_hardware + sell_infra + sell_labor

    {
      details: {
        hardware_kit: sell_hardware,
        infrastructure: sell_infra,
        labor: sell_labor,
        
        total_cost: raw_cost_cameras + raw_cost_central + raw_cost_extras + raw_cost_infra + raw_cost_labor,
        net_profit: grand_total - (raw_cost_cameras + raw_cost_central + raw_cost_extras + raw_cost_infra + raw_cost_labor),
        
        dvr_type: get_dvr_name(@total),
        hdd_size: get_hdd_name(@total)
      },
      total: grand_total
    }
  end

  # --- COST HELPERS ---
  def get_dvr_cost(count)
    if count <= 4 then 4500
    elsif count <= 8 then 6500
    elsif count <= 16 then 10000 
    else 22000 end
  end

  def get_hdd_cost(count)
    if count <= 4 then 2500       # 500GB
    elsif count <= 8 then 4000    # 1TB
    elsif count <= 16 then 6000   # 2TB
    else 9500 end                 # 4TB
  end
  
  def get_psu_cost(count)
    if count <= 4 then 1000
    elsif count <= 16 then 2500   
    else 5000 end
  end

  private

  def get_hdd_name(count)
    if count <= 4 then "500GB HDD"
    elsif count <= 8 then "1TB HDD"
    elsif count <= 12 then "2TB HDD"
    else "4TB HDD" end
  end

  def get_dvr_name(count)
    if count <= 4 then "4-Channel DVR"
    elsif count <= 8 then "8-Channel DVR"
    elsif count <= 16
     "16-Channel DVR"
    else
     "32-Channel DVR"
    end
  end
end