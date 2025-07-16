# frozen_string_literal: true

class FixSetToSectionTypes < ActiveRecord::Migration[8.0]
  def up
    # Fix settings with type 'set' to use 'section' instead
    # This addresses the issue where section-type settings were created with type 'set'
    # instead of type 'section' in the original data migrations
    
    # Update settings that should be sections (type 6 -> type 0)
    Setting.where(type: 6).update_all(type: 0)  # 6 = 'set', 0 = 'section'
    
    puts "Fixed #{Setting.where(type: 0).count} settings from 'set' to 'section' type"
  end

  def down
    # Reverse the operation if needed
    # Note: This assumes all section-type settings should be reverted to 'set'
    # In practice, this might not be desirable, but included for completeness
    
    Setting.where(type: 0).update_all(type: 6)  # 0 = 'section', 6 = 'set'
    
    puts "Reverted section-type settings back to 'set' type"
  end
end
