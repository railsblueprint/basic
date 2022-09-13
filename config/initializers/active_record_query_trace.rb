if Rails.env.development?
  ActiveRecordQueryTrace.enabled = ENV['active_record_query_trace'].to_b
  ActiveRecordQueryTrace.colorize = :light_purple
  ActiveRecordQueryTrace.lines = 10
end
