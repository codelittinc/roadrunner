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

ActiveRecord::Schema.define(version: 2020_07_03_152350) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "flow_requests", force: :cascade do |t|
    t.string "json"
    t.string "flow_name"
    t.boolean "executed"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "error_message"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "pull_requests", force: :cascade do |t|
    t.string "head"
    t.string "base"
    t.integer "github_id"
    t.string "title"
    t.string "description"
    t.string "state"
    t.string "owner"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "repository_id"
    t.bigint "user_id"
    t.index ["repository_id"], name: "index_pull_requests_on_repository_id"
    t.index ["user_id"], name: "index_pull_requests_on_user_id"
  end

  create_table "repositories", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "project_id"
    t.string "deploy_type"
    t.boolean "supports_deploy"
    t.string "name"
    t.string "jira_project"
    t.string "alias"
    t.index ["project_id"], name: "index_repositories_on_project_id"
  end

  create_table "server_incidents", force: :cascade do |t|
    t.string "message"
    t.bigint "server_id"
    t.bigint "server_status_check_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["server_id"], name: "index_server_incidents_on_server_id"
    t.index ["server_status_check_id"], name: "index_server_incidents_on_server_status_check_id"
  end

  create_table "server_status_checks", force: :cascade do |t|
    t.integer "code"
    t.bigint "server_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["server_id"], name: "index_server_status_checks_on_server_id"
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

  add_foreign_key "pull_requests", "repositories"
  add_foreign_key "pull_requests", "users"
  add_foreign_key "slack_repository_infos", "repositories"
end
