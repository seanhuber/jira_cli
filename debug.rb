# bundle exec ruby debug.rb

require 'jira_cli'
require 'ap'

jira = JiraCli::Wrapper.new

ap jira.get_server_info

begin

  ap jira.create_project(key: 'DELETEME', lead: 'shuber')

  ap jira.create_issue(key: 'DELETEME', type: 'Bug', summary: 'This is a test issue')

  issue_id = jira.get_issue_list(jql: 'project=DELETEME').keys[0]

  ap jira.add_attachment(issue: issue_id, file: 'README.md')
  attachment_id = jira.get_attachment_list(issue: issue_id).keys[0]
  ap jira.remove_attachment(issue: issue_id, id: attachment_id)

  ap jira.add_comment issue: issue_id, comment: 'testing an automated comment'
  comment_id = jira.get_comment_list(issue: issue_id).keys[0]
  ap jira.remove_comment(issue: issue_id, id: comment_id)

  ap jira.delete_issue(issue: issue_id)

  ap jira.delete_project(key: 'DELETEME')

  issue_type_scheme_id = jira.get_issue_type_scheme_list(regex: 'DELETEME.*').keys[0]
  ap jira.delete_issue_type_scheme(id: issue_type_scheme_id)

  workflow_scheme_id = jira.get_workflow_scheme_list(regex: 'DELETEME.*').keys[0]
  ap jira.delete_workflow_scheme(id: workflow_scheme_id)

  workflow_name = jira.get_workflow_list(regex: 'Software Simplified Workflow for Project DELETEME.*').keys[0]
  ap jira.delete_workflow(name: workflow_name)

  issue_type_screen_scheme_id = jira.get_issue_type_screen_scheme_list(regex: 'DELETEME.*').keys[0]
  ap jira.delete_issue_type_screen_scheme(id: issue_type_screen_scheme_id)

  jira.get_screen_scheme_list(regex: 'DELETEME.*').keys.each do |screen_scheme_id|
    ap jira.delete_screen_scheme(id: screen_scheme_id)
  end

  jira.get_screen_list(regex: 'DELETEME.*').keys.each do |screen_id|
    ap jira.delete_screen(id: screen_id)
  end

rescue JiraCli::OutputError => e
  ap [e.actual_output, e.message]
end
