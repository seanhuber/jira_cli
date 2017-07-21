require 'jira_cli'
require 'ap'

jira = JiraCli::Wrapper.new

# ap jira.get_server_info

begin

  ap jira.get_issue_type_scheme_list
  ap jira.get_workflow_scheme_list
  ap jira.get_workflow_list

rescue JiraCli::OutputError => e
  ap [e.actual_output, e.message]
end
