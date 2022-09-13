# frozen_string_literal: true

class AddRoles < ActiveRecord::Migration[7.0]
  def up
    Role.create(name: "superadmin")
    Role.create(name: "admin")
    Role.create(name: "moderator")
  end

  def down
  end
end
