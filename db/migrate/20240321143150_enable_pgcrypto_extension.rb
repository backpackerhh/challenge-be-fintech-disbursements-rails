# frozen_string_literal: true

class EnablePgcryptoExtension < ActiveRecord::Migration[7.1]
  def up
    return if extension_enabled?("pgcrypto")

    enable_extension "pgcrypto"
  end

  def down
    return unless extension_enabled?("pgcrypto")

    disable_extension "pgcrypto"
  end
end
