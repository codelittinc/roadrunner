# frozen_string_literal: true

require 'json'

module Flows
  class JiraIssuesReportFlow < BaseFlow
    STATUS_NAME = 'DONE'
    PROJECT_ID = 'AYPI'

    def execute
      issues_by_day = issues.group_by do |issue|
        issue['fields']['created'].scan(/^\d+-\d+-\d+/).first
      end

      last_seven_days = ((DateTime.now - 7.days)..(DateTime.now)).map {|d| d.strftime('%Y-%m-%d')}

      issues_by_day = issues_by_day.filter do |issue| 
        last_seven_days.include?(issue)
      end
      puts issues_by_day.count


      main_report = {}

      issues_by_day.each do |month, issues|
        data = issues.map do |issue|
          fields = issue['fields']
          {
            key: issue['key'],
            project: issue['fields']['project']['key'],
           # assignee: fields.dig('assignee', 'displayName'),
            created: fields['created'],
            type: fields.dig('issuetype', 'name'),
           # estimate: fields['customfield_10023']
          }
        end

        bugs_by_project = data.select { |d| d[:type] == 'Bug' }.group_by do |i| i[:project] end
        bugs_by_project = bugs_by_project.each do |k, v|
          bugs_by_project[k] = v.count
        end
        report = {}
       # report[:number_of_cards] = issues.size
        report[:bugs_by_project] = bugs_by_project
        report[:number_of_cards_without_estimates] = data.reject { |d| d[:estimate] }.size
     #   report[:percentage_of_bugs_cards] = (report[:number_of_bugs] * 100) / report[:number_of_cards]
     #   report[:types_of_issues] = Set.new(data.pluck(:type)).to_a
     #   report[:percentage_of_bugs_time] = (report[:number_of_bugs] * 100) / report[:number_of_cards]
     #   report[:estimates] = Set.new(data.pluck(:estimate)).to_a
        main_report[month] = report
      end

      main_report[:total_bugs] = main_report.map { |k,v| v[:bugs_by_project] }.map {|k,v| k.values }.sum {|v| v.sum}
#      main_report[:total_without_estimates] = main_report.map { |k,v| v[:number_of_cards_without_estimates] }.map {|k,v| k.values }.sum {|v| v.sum}

      puts main_report

      Request.post('https://hooks.zapier.com/hooks/catch/4254966/oaq4b0w/silent/', '', main_report.to_json)
    end

    def flow?
      text == 'reports jira'
    end

    private

    def text
      @text ||= @params[:text]
    end

    def issues
      return @issues if @issues

      @issues = []
      projects = ["CW", "HUB", "AYAPI", "AYPI"] # ['AYAPI', 'AYPI']# 

      projects.each do |project|
        start_at = 0
        max_results = 100
        has_issues_to_fetch = true

        while has_issues_to_fetch
          response = Clients::Jira::Issue.new.list_all(project, max_results, start_at)
          has_issues_to_fetch = !response.empty?
          @issues << response
          start_at += max_results
        end

      end
      @issues.flatten!
    end
  end
end
