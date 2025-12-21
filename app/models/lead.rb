class Lead < ApplicationRecord
	has_many :quotes, dependent: :destroy

	validates :phone, presence: true
  
  # 2. Email is optional, but if present, let's make sure it looks like an email
  # (Optional: You can remove this line if you want to allow simple text)
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
