# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_31_212103) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "repositories", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "project_id"
    t.string "deploy_type"
    t.boolean "supports_deploy"
    t.string "name"
    t.string "jira_project"
    t.index ["project_id"], name: "index_repositories_on_project_id"
  end

  create_table "servers", force: :cascade do |t|
    t.string "link"
    t.boolean "supports_health_check"
    t.bigint "repository_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "alias"
    t.boolean "active", default: true
    t.string "environment"
    t.index ["repository_id"], name: "index_servers_on_repository_id"
  end

  create_table "slack_repository_infos", force: :cascade do |t|
    t.string "deploy_channel"
    t.bigint "repository_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "dev_channel"
    t.string "dev_group"
    t.index ["repository_id"], name: "index_slack_repository_infos_on_repository_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "github"
    t.string "jira"
    t.string "slack"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "slack_repository_infos", "repositories"
end
