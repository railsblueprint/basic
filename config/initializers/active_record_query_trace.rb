if Rails.env.development?
  begin
    ActiveRecordQueryTrace.enabled = ENV['active_record_query_trace'].to_b
    ActiveRecordQueryTrace.colorize = :light_purple
    ActiveRecordQueryTrace.lines = 10
  rescue NameError
    # ActiveRecordQueryTrace gem not available - skip configuration
  end
end
