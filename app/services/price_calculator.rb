class PriceCalculator
  # --- COSTS ---
  COST_CAM_INDOOR  = 1500
  COST_CAM_OUTDOOR = 2000
  COST_DVR_4CH  = 4200
  COST_DVR_8CH  = 6000
  COST_DVR_16CH = 11000
  COST_HDD_500GB = 2500
  COST_HDD_1TB   = 4200
  COST_HDD_2TB   = 6500
  COST_HDD_4TB   = 10500
  COST_PSU_SMALL = 1000
  COST_PSU_MED   = 2500
  COST_PSU_LARGE = 5000
  COST_MONITOR = 3500 
  COST_UPS     = 5500 
  COST_INFRA_PER_CAM = 800 
  PAY_TECH_PER_CAM = 1000
  PAY_TRANSPORT    = 2000 

  def initialize(total, outdoor, building_type, floors, days, monitor, ups)
    @total = total.to_i
    @outdoor = outdoor.to_i
    @indoor = @total - @outdoor
    @building_type = building_type 
    @floors = floors.to_i
    @days = days.to_i
    
    # DEBUGGING: Print to your terminal to see what is actually happening
    puts "========================================"
    puts "DEBUG: Total: #{@total}"
    puts "DEBUG: Monitor Param: #{monitor.inspect}"
    puts "DEBUG: UPS Param: #{ups.inspect}"
    
    # SAFE BOOLEAN CONVERSION
    # Handles "1", "true", true, 1
    @monitor = [true, "true", "1", 1].include?(monitor)
    @ups = [true, "true", "1", 1].include?(ups)

    puts "DEBUG: Final Monitor Logic: #{@monitor}"
    puts "========================================"
  end

  def calculate
    # 1. Hardware
    raw_cams = (@indoor * COST_CAM_INDOOR) + (@outdoor * COST_CAM_OUTDOOR)
    raw_central = get_dvr_cost(@total) + get_hdd_cost(@total, @days) + get_psu_cost(@total)
    
    # 2. Extras (ONLY add if true)
    raw_extras = 0
    raw_extras += COST_MONITOR if @monitor
    raw_extras += COST_UPS if @ups

    # 3. Infrastructure & Labor
    raw_infra = @total * COST_INFRA_PER_CAM
    raw_infra += 2000 if @total > 8

    transport_cost = @total <= 4 ? 1500 : PAY_TRANSPORT
    raw_labor = (@total * PAY_TECH_PER_CAM) + transport_cost
    if @floors > 1
      raw_labor += (@floors - 1) * 500
    end

    # 4. MARGIN LOGIC (Aggressive for small jobs)
    if @total <= 4
      margin_percent = 0.20 # 20% for 4-cam jobs
    elsif @total <= 8
      margin_percent = 0.30
    else
      margin_percent = 0.35
    end

    # Apply Margin
    sell_hardware = ((raw_cams + raw_central) * (1 + margin_percent))
    sell_extras   = (raw_extras * 1.20) # Low margin on extras
    sell_infra    = (raw_infra * (1 + margin_percent))
    sell_labor    = (raw_labor * (1 + margin_percent))

    # Rounding
    sell_hardware = round_up(sell_hardware + sell_extras)
    sell_infra    = round_up(sell_infra)
    sell_labor    = round_up(sell_labor)

    grand_total = sell_hardware + sell_infra + sell_labor

    # Minimum Price Safety Net
    min_price = @total <= 4 ? 24000 : 35000
    grand_total = [grand_total, min_price].max

    {
      details: {
        hardware_kit: sell_hardware,
        infrastructure: sell_infra,
        labor: sell_labor,
        dvr_type: get_dvr_name(@total),
        hdd_size: get_hdd_name(@total, @days),
        monitor_included: @monitor ? "Yes" : "No",
        ups_included: @ups ? "Yes" : "No"
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
    if count <= 4 && days <= 7 then COST_HDD_500GB
    elsif count <= 8 && days <= 7 then COST_HDD_1TB
    elsif count <= 16 then COST_HDD_2TB
    else COST_HDD_4TB end
  end
  
  def get_hdd_name(count, days)
    if count <= 4 && days <= 7 then "500GB Surveillance HDD"
    elsif count <= 8 && days <= 7 then "1TB Surveillance HDD"
    else "2TB/4TB Surveillance HDD" end
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