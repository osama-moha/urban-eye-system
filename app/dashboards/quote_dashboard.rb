require "administrate/base_dashboard"

class QuoteDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    lead: Field::BelongsTo,
    
    # 1. FIX: Use 'total_amount' instead of 'estimated_price'
    # Added formatting so it shows "KES 81,900.00"
    total_amount: Field::Number.with_options(
      prefix: "KES ", 
      decimals: 2
    ),

    # 2. ADD: All the missing fields from your form
    camera_count: Field::Number,
    outdoor_count: Field::Number,
    floors: Field::Number,
    recording_days: Field::Number,
    
    building_type: Field::String,
    purpose: Field::String,
    timeline: Field::String,
    
    monitor: Field::Boolean,
    ups: Field::Boolean,

    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # Attributes displayed on the main list page
  COLLECTION_ATTRIBUTES = %i[
    id
    lead
    total_amount
    building_type
    camera_count
    created_at
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # Attributes displayed on the "Show" page (The one in your screenshot)
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    lead
    total_amount
    camera_count
    outdoor_count
    floors
    building_type
    purpose
    timeline
    recording_days
    monitor
    ups
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # Attributes displayed on the "Edit" page in Admin
  FORM_ATTRIBUTES = %i[
    lead
    total_amount
    camera_count
    outdoor_count
    floors
    building_type
    purpose
    timeline
    recording_days
    monitor
    ups
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  # Optional: Customize the label for quotes in dropdowns
  def display_resource(quote)
    "Quote ##{quote.id}"
  end
end