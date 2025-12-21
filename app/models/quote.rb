class Quote < ApplicationRecord
  belongs_to :lead

  # 1. Must have at least 1 camera
  validates :camera_count, presence: true, numericality: { greater_than: 0, only_integer: true }
  
  # 2. These fields are required for the math to work
  validates :floors, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :building_type, presence: true
  validates :recording_days, presence: true
end
