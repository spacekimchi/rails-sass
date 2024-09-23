# == Schema Information
#
# Table name: support_ticket_messages
#
#  id                :bigint           not null, primary key
#  support_ticket_id :bigint           not null
#  user_id           :bigint           not null
#  content           :text             not null
#  recipient_email   :text
#  internal          :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class SupportTicketMessage < ApplicationRecord
  belongs_to :support_ticket
end
