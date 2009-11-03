class AddLocaleToConfiguration < ActiveRecord::Migration
  def self.up
    add_column :configurations, :locale, :string, :default => "en"
  end

  def self.down
    remove_column :configurations, :locale
  end
end
