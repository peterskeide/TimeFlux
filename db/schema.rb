# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090923094349) do

  create_table "activities", :force => true do |t|
    t.string   "name",                                :null => false
    t.string   "description"
    t.integer  "project_id"
    t.boolean  "active",           :default => true
    t.boolean  "default_activity", :default => false
    t.boolean  "shared",           :default => false
    t.boolean  "template",         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "activities_tags", :id => false, :force => true do |t|
    t.integer  "activity_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "activities_users", :id => false, :force => true do |t|
    t.integer  "activity_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "customers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "billable",   :default => true
  end

  create_table "holidays", :force => true do |t|
    t.date     "date"
    t.string   "note"
    t.boolean  "repeat"
    t.float    "working_hours"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hour_types", :force => true do |t|
    t.string   "name"
    t.boolean  "default_hour_type", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects_users", :id => false, :force => true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tag_types", :force => true do |t|
    t.string   "name"
    t.string   "icon"
    t.boolean  "mutually_exclusive", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "tag_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags_time_entries", :id => false, :force => true do |t|
    t.integer  "time_entry_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "time_entries", :force => true do |t|
    t.float    "hours",        :default => 0.0
    t.boolean  "counterpost",  :default => false
    t.string   "notes"
    t.date     "date",                            :null => false
    t.integer  "activity_id"
    t.integer  "user_id"
    t.integer  "hour_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",       :default => 0
  end

  create_table "users", :force => true do |t|
    t.string   "firstname",                            :null => false
    t.string   "lastname",                             :null => false
    t.string   "login",                                :null => false
    t.string   "email",                                :null => false
    t.string   "crypted_password",                     :null => false
    t.string   "password_salt",                        :null => false
    t.string   "persistence_token",                    :null => false
    t.string   "operative_status"
    t.boolean  "admin",             :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
