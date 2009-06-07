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

ActiveRecord::Schema.define(:version => 20090606151753) do

  create_table "activities", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.boolean  "active"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assignments", :force => true do |t|
    t.integer  "project_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "persons", :force => true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "username"
    t.string   "password"
    t.string   "email"
    t.string   "operative_status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "time_entries", :force => true do |t|
    t.float    "hours"
    t.boolean  "billed"
    t.boolean  "locked"
    t.boolean  "counterpost"
    t.string   "notes"
    t.date     "date"
    t.integer  "week_entry_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "week_entries", :force => true do |t|
    t.boolean  "locked"
    t.integer  "year"
    t.integer  "week_number"
    t.integer  "person_id"
    t.integer  "activity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
