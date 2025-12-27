class PriceCalculator
  # ==========================================
  # 1. HARDWARE PRICES (Your Nairobi Rates)
  # ==========================================
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

  MONITOR_PRICE = 3500 
  UPS_PRICE = 6500

  # ==========================================
  # 2. INFRASTRUCTURE & LABOR
  # ==========================================
  CABLE_BOX_PRICE = 4500     
  CABLE_PER_METER = 40       
  VIDEO_BALUN_PAIR = 350     
  INFRA_KIT_PER_CAM = 400  

  BASE_LABOR_FEE = 1500       
  LABOR_PER_CAMERA = 1700
  
  COMMERCIAL_SURCHARGE = 500
  INDUSTRIAL_SURCHARGE = 5000
  FLOOR_TAX = 500

  # ==========================================
  # 3. NEW: SUBSCRIPTION CONSTANTS
  # ==========================================
  SUB_STARTER_INSTALL_FEE = 7999  # Upfront
  SUB_STARTER_MONTHLY_FEE = 2900  # Monthly

  def initialize(total, outdoor, building_type, floors, days, monitor, ups, subscription_mode = false)
    @total = total.to_i
    @outdoor = outdoor.to_i
    @indoor = @total - @outdoor
    @building_type = building_type 
    @floors = floors.to_i
    @days = days.to_i
    
    # Safe Boolean Check
    @monitor = [true, "true", "1", 1].include?(monitor)
    @ups = [true, "true", "1", 1].include?(ups)
    
    # Check for Subscription Mode
    @subscription_mode = [true, "true", "1", 1].include?(subscription_mode)
  end

  def calculate
    # ------------------------------------------------
    # PATH A: SUBSCRIPTION MODE (Starter Shield)
    # ------------------------------------------------
    if @subscription_mode
      return calculate_subscription_package
    end

    # ------------------------------------------------
    # PATH B: STANDARD QUOTE (Your Code)
    # ------------------------------------------------
    
    # 1. Hardware Costs
    cost_camera_indoor  = 2000
    cost_camera_outdoor = 2800 
    
    raw_cost_cameras = (@indoor * cost_camera_indoor) + (@outdoor * cost_camera_outdoor)
    raw_cost_central = get_dvr_cost(@total) + get_hdd_cost(@total) + get_psu_cost(@total)

    # Add Monitor/UPS if selected
    if @monitor
      raw_cost_central += MONITOR_PRICE
    end
    
    if @ups
      raw_cost_central += UPS_PRICE
    end

    # 2. Infrastructure Costs
    cost_infra_per_cam = 300 
    raw_cost_infra = @total * cost_infra_per_cam
    
    if @total > 8
      raw_cost_infra += 500 
    end

    # 3. Labor Costs
    tech_rate_per_cam = 1000
    
    # FIX: Calculate floor fee ONCE to avoid double charging
    tech_floor_fee = (@floors > 1) ? (@floors * 500) : 0
    tech_base_fee = 500
   
    raw_cost_labor = (@total * tech_rate_per_cam) + tech_floor_fee + tech_base_fee

    case @building_type
    when "Commercial / Office"
      raw_cost_labor += COMMERCIAL_SURCHARGE
    when "Industrial / Warehouse"
      raw_cost_labor += INDUSTRIAL_SURCHARGE
    end

    # REMOVED: The second "if @floors > 1" block was here. 
    # It is already included in `tech_floor_fee` above.

    # ==========================================
    # STEP 2: APPLY YOUR PROFIT MARGIN
    # ==========================================
    markup_percent = if @total <= 8
                        0.15
                      else
                        0.30
                      end

    sell_hardware = (raw_cost_cameras + raw_cost_central).to_f * (1 + markup_percent)
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
        dvr_type: get_dvr_name(@total),
        hdd_size: get_hdd_name(@total),
        monitor_included: @monitor ? "Yes" : "No",
        ups_included: @ups ? "Yes" : "No",
        is_subscription: false
      },
      total: grand_total
    }
  end

  # --- HELPERS ---
  def get_dvr_cost(count)
    if count <= 4 then DVR_4_CH
    elsif count <= 8 then DVR_8_CH
    else DVR_16_CH end
  end

  def get_hdd_cost(count)
    if count <= 4 then HDD_500GB
    elsif count <= 8 then HDD_1TB
    elsif count <= 16 then HDD_2TB
    else HDD_4TB end
  end
  
  def get_psu_cost(count)
    if count <= 4 then PSU_SMALL
    elsif count <= 8 then PSU_MED
    else PSU_LARGE end
  end
  
  private

  # --- SUBSCRIPTION HELPER ---
  def calculate_subscription_package
    {
      details: {
        package_name: "Urban Eye Starter Shield",
        hardware_kit: "Included (Rental)",
        infrastructure: "Included",
        labor: SUB_STARTER_INSTALL_FEE, 
        dvr_type: "4-Channel DVR (Internet Ready)",
        hdd_size: "500GB (Loop Recording)",
        monitor_included: "No (Mobile App Only)",
        ups_included: "No",
        is_subscription: true,
        monthly_fee: SUB_STARTER_MONTHLY_FEE,
        upfront_fee: SUB_STARTER_INSTALL_FEE
      },
      total: SUB_STARTER_INSTALL_FEE
    }
  end

  def get_hdd_name(count)
    if count <= 4 then "500GB HDD"
    elsif count <= 8 then "1TB HDD"
    else "2TB/4TB HDD" end
  end

  def get_dvr_name(count)
    if count <= 4 then "4-Channel DVR"
    elsif count <= 8 then "8-Channel DVR"
    else "16-Channel DVR" end
  end
end