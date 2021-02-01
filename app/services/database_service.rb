# frozen_string_literal: true

require 'open3'

class DatabaseService
  def backup_restore_db(db_data, force: false)
    cmd_bash = "sh #{File.expand_path('../../lib/scripts/backup.sh', __dir__)} --filename='#{db_data['filename']}'" \
    " --source_host='#{db_data['source_host']}' --source_database='#{db_data['source_database']}'" \
    " --source_user='#{db_data['source_user']}' --source_password='#{db_data['source_password']}'" \
    " --destination_host='#{db_data['destination_host']}' --destination_database='#{db_data['destination_database']}'" \
    " --destination_user='#{db_data['destination_user']}' --destination_password='#{db_data['destination_password']}'" \
    "  #{'--force' if force}"

    _stdout, _stderr, status = Open3.capture3(cmd_bash)
    status.success? ? 'Command executed with success!' : 'Command failed'
  end
end
