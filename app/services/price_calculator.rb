class PriceCalculator
  # --- 1. HARDWARE PRICES (Nairobi Market Rates) ---
  # DVRs (Hikvision/Dahua avg)
  DVR_4_CH = 4500
  DVR_8_CH = 7500   # Includes margin
  DVR_16_CH = 10000 # Includes margin

  # HDDs (Surveillance Grade)
  HDD_500GB = 3000  # Rarely used now, but okay
  HDD_1TB = 4500
  HDD_2TB = 6000
  HDD_4TB = 17500

  # Power Supply Units (Dynamic)
  PSU_SMALL = 1500  # 5A-10A (For 1-4 cams)
  PSU_MED   = 3500  # 10A-20A Box (For 5-8 cams)
  PSU_LARGE = 6000  # 30A Heavy Duty Box (For 9-16 cams)

  # Monitor & UPS
  MONITOR_PRICE = 4500 # 2.5k is too low for a decent HDMI monitor. 4.5k is safe.
  UPS_PRICE = 6500

  # --- 2. INFRASTRUCTURE PRICES ---
  # Cable: Real Premium Copper is ~17,500. CCA is ~4,500.
  CABLE_BOX_PRICE = 4500   
  CABLE_PER_METER = 40      # Selling price per meter (includes waste)
  VIDEO_BALUN_PAIR = 350    # Pair of Baluns + DC Jacks
  
  # The "Infrastructure Lot" Buffer (Trunking, Boxes, Tape, Ties)
  # We calculate this as a fixed amount PER CAMERA to cover miscellaneous materials.
  INFRA_KIT_PER_CAM = 400 

  # --- 3. LABOR PRICES ---
  BASE_LABOR_FEE = 2800     # Transport + Mobilization
  LABOR_PER_CAMERA = 1700
  
  # Surcharges
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
    @monitor = monitor.to_s == "1" || monitor == true
    @ups = ups.to_s == "1" || ups == true
  end

  def calculate
    # ==========================================
    # STEP 1: CALCULATE YOUR "BUYING PRICE" (COSTS)
    # ==========================================
    
    # 1. Hardware Costs (Based on your list)
    cost_camera_indoor  = 1500
    cost_camera_outdoor = 2000 # Estimate (usually slightly more)
    
    # Calculate Camera Cost
    raw_cost_cameras = (@indoor * cost_camera_indoor) + (@outdoor * cost_camera_outdoor)
    
    # Calculate Central Unit Cost (DVR + HDD + PSU)
    raw_cost_central = get_dvr_cost(@total) + get_hdd_cost(@total) + get_psu_cost(@total)

    # 2. Infrastructure Costs (Cables & Clips)
    # You listed: 2 Boxes (5000), Baluns (1800), Jacks (480), Boxes (1600), Consumables (1150)
    # This averages to roughly 850 KES per camera in materials.
    cost_infra_per_cam = 900 
    raw_cost_infra = @total * cost_infra_per_cam
    
    # If job is big (>8 cams), add cost for bulk cable boxes
    if @total > 8
      raw_cost_infra += 2000 # Buffer for extra cable box
    end

    # 3. Labor Costs (The Technician)
    # You pay the technician 1000 per camera.
    tech_rate_per_cam = 1000
    
    # Technicians often charge extra for high floors (e.g. 500 per floor above 2nd)
    tech_floor_fee = (@floors > 1) ? (@floors * 500) : 0
    
    # Add a base "Transport/Configuration" fee for the tech (e.g. 2000)
   tech_base_fee = 2000
   
   raw_cost_labor = (@total * tech_rate_per_cam) + tech_floor_fee + tech_base_fee

   # --- [START NEW CODE] ---
   # Apply Surcharges defined in your constants
   case @building_type
   when "Commercial / Office"
     raw_cost_labor += COMMERCIAL_SURCHARGE
   when "Industrial / Warehouse"
     raw_cost_labor += INDUSTRIAL_SURCHARGE
   end

   # Apply Vertical Tax if floors > 1 (Using your FLOOR_TAX constant)
   if @floors > 1
     raw_cost_labor += (@floors * FLOOR_TAX)
   end
   # --- [END NEW CODE] ---

   # ==========================================
   # STEP 2: APPLY YOUR PROFIT MARGIN
   # ==========================================
    # Determine Markup %
    # 15% for small jobs, 30% for big jobs
    markup_percent = if @total <= 8
                       0.15
                     else
                       0.30
                     end

    # Calculate Selling Prices (Cost + Profit)
    # We apply the markup to EACH section so the quote looks balanced.
    
    sell_hardware = (raw_cost_cameras + raw_cost_central).to_f * (1 + markup_percent)
    sell_infra    = raw_cost_infra.to_f * (1 + markup_percent)
    sell_labor    = raw_cost_labor.to_f * (1 + markup_percent)

    # Rounding to nice numbers (Nearest 100)
    sell_hardware = sell_hardware.ceil(-2)
    sell_infra    = sell_infra.ceil(-2)
    sell_labor    = sell_labor.ceil(-2)
    
    grand_total = sell_hardware + sell_infra + sell_labor

    {
      details: {
        hardware_kit: sell_hardware,
        infrastructure: sell_infra,
        labor: sell_labor,
        
        # Keep these for your internal dashboard so you see your Net Profit
        total_cost: raw_cost_cameras + raw_cost_central + raw_cost_infra + raw_cost_labor,
        net_profit: grand_total - (raw_cost_cameras + raw_cost_central + raw_cost_infra + raw_cost_labor),
        
        dvr_type: get_dvr_name(@total),
        hdd_size: get_hdd_name(@total)
      },
      total: grand_total
    }
  end

  # --- COST HELPERS (Updated with your specific costs) ---
  def get_dvr_cost(count)
    if count <= 4 then 4500
    elsif count <= 8 then 6500
    elsif count <= 16 then 10000 # ✅ Your 10k Cost
    else 22000 end
  end

  def get_hdd_cost(count)
    if count <= 4 then 2500       # 500GB
    elsif count <= 8 then 4000    # 1TB
    elsif count <= 16 then 6000   # ✅ Your 6k Cost (2TB)
    else 9500 end                 # 4TB
  end
  
  def get_psu_cost(count)
    if count <= 4 then 1000
    elsif count <= 16 then 2500   # ✅ Your 2.5k Cost (30A)
    else 5000 end
  end

  private

  def get_hdd_price(count)
    if count <= 4 then HDD_500GB
    elsif count <= 8 then HDD_1TB
    elsif count <= 12 then HDD_2TB
    else HDD_4TB end
  end
  
  def get_hdd_name(count)
    if count <= 4 then "500GB HDD"
    elsif count <= 8 then "1TB HDD"
    elsif count <= 12 then "2TB HDD"
    else "4TB HDD" end
  end

  def get_dvr_price(count)
    if count <= 4 then DVR_4_CH
    elsif count <= 8 then DVR_8_CH
    else DVR_16_CH end
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

  # NEW: Dynamic Power Supply Logic
  def get_psu_price(count)
    if count <= 4
      PSU_SMALL
    elsif count <= 8
      PSU_MED
    else
      PSU_LARGE
    end
  end
end