# == Schema Information
#
# Table name: support_tickets
#
#  id             :bigint           not null, primary key
#  user_id        :bigint
#  author_email   :string           not null
#  subject        :string           not null
#  status         :integer          default("open"), not null
#  priority       :integer          default("low"), not null
#  content        :text             not null
#  resolved_at    :datetime
#  assigned_to_id :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class SupportTicket < ApplicationRecord
  LOW = :low
  OPEN = :open
  belongs_to :user, optional: true
  belongs_to :assigned_to, class_name: 'User', optional: true

  validates :author_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :subject, presence: true
  validates :content, presence: true

  enum status: { open: 0, in_progress: 1, closed: 2 }
  enum priority: { low: 0, medium: 1, high: 2, critical: 3 }

  def assign_to_user(user)
    update(assigned_to: user)
  end
end
