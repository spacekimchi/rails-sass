# == Schema Information
#
# Table name: application_errors
#
#  id               :bigint           not null, primary key
#  message          :text
#  level            :integer
#  code             :integer
#  calling_function :text
#  stack_trace      :text
#  url              :text
#  user_id          :text
#  user_ip          :text
#  user_agent       :text
#  is_resolved      :boolean
#  resolved_at      :datetime
#  notes            :text
#  data             :jsonb
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class ApplicationError < ApplicationRecord
  enum level: { triage: 0, low: 1, medium: 2, high: 3, critical: 4 }

  def with_backtrace_from_error(e)
    self.backtrace = "\n\t#{e.backtrace.join("\n\t")}"
    self
  end
end
