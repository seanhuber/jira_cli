# bundle exec ruby debug.rb

require 'jira_cli'
require 'ap'

jira = JiraCli::Wrapper.instance

ap jira.get_server_info

begin

  ap jira.create_project(project: 'DELETEME', lead: 'shuber')

  ap jira.add_version(project: 'DELETEME', name: 'deleteme_v1.2.3', description: 'this is a test release', start_date: Date.new(2017, 7, 13), date: Date.new(2017, 8, 21))
  version_id = jira.get_version_list(project: 'DELETEME', parse_response: true).keys[0]
  ap jira.release_version(project: 'DELETEME', version: version_id)
  ap jira.delete_version(project: 'DELETEME', version: version_id)

  ap jira.create_issue(project: 'DELETEME', type: 'Bug', summary: 'This is a test issue')

  issue_id = jira.get_issue_list(jql: 'project=DELETEME', parse_response: true).keys[0]

  ap jira.transition_issue(issue: issue_id, transition: 'In Review')

  ap jira.add_attachment(issue: issue_id, file: 'README.md')
  attachment_id = jira.get_attachment_list(issue: issue_id, parse_response: true).keys[0]
  ap jira.remove_attachment(issue: issue_id, id: attachment_id)

  ap jira.add_comment issue: issue_id, comment: 'testing an automated comment'
  comment_id = jira.get_comment_list(issue: issue_id, parse_response: true).keys[0]
  ap jira.remove_comment(issue: issue_id, id: comment_id)

  ap jira.delete_issue(issue: issue_id)

  ap jira.delete_project(project: 'DELETEME')

  issue_type_scheme_id = jira.get_issue_type_scheme_list(regex: 'DELETEME.*', parse_response: true).keys[0]
  ap jira.delete_issue_type_scheme(id: issue_type_scheme_id)

  workflow_scheme_id = jira.get_workflow_scheme_list(regex: 'DELETEME.*', parse_response: true).keys[0]
  ap jira.delete_workflow_scheme(id: workflow_scheme_id)

  workflow_name = jira.get_workflow_list(regex: 'Software Simplified Workflow for Project DELETEME.*', parse_response: true).keys[0]
  ap jira.delete_workflow(workflow: workflow_name)

  issue_type_screen_scheme_id = jira.get_issue_type_screen_scheme_list(regex: 'DELETEME.*', parse_response: true).keys[0]
  ap jira.delete_issue_type_screen_scheme(id: issue_type_screen_scheme_id)

  jira.get_screen_scheme_list(regex: 'DELETEME.*', parse_response: true).keys.each do |screen_scheme_id|
    ap jira.delete_screen_scheme(id: screen_scheme_id)
  end

  jira.get_screen_list(regex: 'DELETEME.*', parse_response: true).keys.each do |screen_id|
    ap jira.delete_screen(id: screen_id)
  end

rescue JiraCli::OutputError => e
  ap [e.actual_output, e.message]
end
