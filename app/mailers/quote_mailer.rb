class QuoteMailer < ApplicationMailer
  # 1. Set the default sender (can be a generic address for now)
  default from: 'notifications@urbaneye.co.ke'

  def new_quote_alert
    @quote = params[:quote]
    @lead = @quote.lead
    
    # 2. Who receives the alert? (Put YOUR email address here)
    @my_email = 'abdulmalikmoha71@gmail.com' 

    # 3. Subject Line Logic (Highlight High-Value Jobs)
    subject_icon = @quote.total_amount > 100000 ? "💰 BIG JOB" : "🔔 New Lead"
    subject_line = "#{subject_icon}: #{@lead.phone} asked for #{@quote.camera_count} Cams (KES #{@quote.total_amount})"

    mail(to: @my_email, subject: subject_line)
  end
end
