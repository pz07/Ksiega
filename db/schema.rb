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

ActiveRecord::Schema.define(:version => 20121202122314) do

  create_table "account", :force => true do |t|
    t.string   "name",       :limit => 256,                 :null => false
    t.float    "balance",                                   :null => false
    t.datetime "created_on",                                :null => false
    t.datetime "updated_on",                                :null => false
    t.integer  "user_id",                   :default => -1, :null => false
  end

  add_index "account", ["user_id"], :name => "index_account_on_user_id"

  create_table "category", :force => true do |t|
    t.string   "name",       :limit => 128,                 :null => false
    t.integer  "parent_id"
    t.datetime "created_on",                                :null => false
    t.datetime "updated_on",                                :null => false
    t.integer  "user_id",                   :default => -1, :null => false
  end

  add_index "category", ["name", "parent_id"], :name => "category_name_key", :unique => true
  add_index "category", ["user_id"], :name => "index_category_on_user_id"

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "session", :force => true do |t|
    t.text     "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "session", ["session_id"], :name => "index_session_on_session_id"
  add_index "session", ["updated_at"], :name => "index_session_on_updated_at"

  create_table "trans", :force => true do |t|
    t.string   "name",              :limit => 256,                 :null => false
    t.integer  "category_id"
    t.date     "trans_date",                                       :null => false
    t.float    "amount",                                           :null => false
    t.integer  "source_account_id"
    t.integer  "dest_account_id"
    t.datetime "created_on",                                       :null => false
    t.datetime "updated_on",                                       :null => false
    t.integer  "return_trans_id"
    t.integer  "user_id",                          :default => -1
  end

  add_index "trans", ["user_id"], :name => "index_trans_on_user_id"

  create_table "user", :force => true do |t|
    t.string   "email",                             :null => false
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token",                 :null => false
    t.integer  "login_count",        :default => 0, :null => false
    t.integer  "failed_login_count", :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "openid_identifier"
  end

  add_index "user", ["openid_identifier"], :name => "index_user_on_openid_identifier"

end
