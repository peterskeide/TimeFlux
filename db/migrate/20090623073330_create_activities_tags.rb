class CreateActivitiesTags < ActiveRecord::Migration
  def self.up
    create_table :activities_tags do |t|
      t.references :activity
      t.references :tag
      t.timestamps
    end
  end

  def self.down
    drop_table :activities_tags
  end
end
