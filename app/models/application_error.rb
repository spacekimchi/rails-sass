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
end
