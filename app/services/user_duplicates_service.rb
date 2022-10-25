# frozen_string_literal: true

class UserDuplicatesService
  def remove_dups
    duplicates = User.find_all_duplicates
    delete = []

    duplicates.each do |group|
      sorted_group = group.sort_by(&:created_at)
      base = sorted_group.first
      dups = sorted_group[1..]

      dups.each do |dup|
        move_to_user(base, dup)
        delete << dup.id
      end
    end

    delete_users(delete)
  end

  def move_to_user(stays_user, go_user)
    go_prs = go_user.pull_requests
    go_prs.each do |pr|
      pr.user = stays_user
      pr.save(validate: false)
    end

    go_issues = go_user.issues
    go_issues.each do |issue|
      issue.user = stays_user
      issue.save(validate: false)
    end

    stays_user.github ||= go_user.github
    stays_user.azure ||= go_user.azure
    stays_user.azure_devops_issues ||= go_user.azure_devops_issues
    stays_user.jira ||= go_user.jira
    stays_user.name ||= go_user.name

    stays_user.save
  end

  def delete_users(ids)
    users = User.where(id: ids)
    users.destroy_all
  end
end
