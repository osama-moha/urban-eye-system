class Quote < ApplicationRecord
  belongs_to :lead

  # 1. FIXED: Allow 0 cameras (for Guarding quotes)
  # Changed "greater_than: 0" to "greater_than_or_equal_to: 0"
  validates :camera_count, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  
  # 2. These fields are required for the math to work
  # (These are fine because your form defaults them to 1 even when hidden)
  validates :floors, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :building_type, presence: true
  validates :recording_days, presence: true
end