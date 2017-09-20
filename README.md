[![Gem Version](https://badge.fury.io/rb/jira_cli.svg)](https://badge.fury.io/rb/jira_cli)
[![Build Status](https://travis-ci.org/seanhuber/jira_cli.svg?branch=master)](https://travis-ci.org/seanhuber/jira_cli)

# jira_cli

A ruby wrapper for JIRA Command Line Interface [Bob Swift Atlassian Add-on](https://bobswift.atlassian.net/wiki/spaces/JCLI)

## System Requirements

* Java version 8 (1.8) or higher).
* Bob Swift's JIRA CLI Client: [CLI Client Installation and Use](https://bobswift.atlassian.net/wiki/display/ACLI/CLI+Client+Installation+and+Use)
  * It is recommended that you follow the best practices and create a shell script encapsulating the jira server URL, username, and password.
  * Alternatively, the `jira_cli` gem can be configured to explictly use these configuration options and the path the the cli jar file.

## Installation

Add to your application's Gemfile:

```ruby
gem 'jira_cli', '~> 1.0'
```

## Usage

`jira_cli` has a wrapper class with all of Bob Swift's JIRA cli actions ([Full documentation here](https://bobswift.atlassian.net/wiki/display/JCLI/Reference)) defined as singleton methods.

### Basic Examples

This example will display the results of the `getServerInfo` cli action:

```ruby
jira = JiraCli::Wrapper.instance
puts jira.get_server_info
```

In general, all singleton methods have the same name as their CLI conterpart except that the name is converted from camel case to underscore and the arguments are keywords.

For example, you might execute the following statement with Bob Swift's CLI:

```
jira --action createIssue --project "PROJKEY" --type "Bug" --summary "This is a new issue"
```

The equivalent in ruby would be:

```ruby
jira = JiraCli::Wrapper.instance
begin
  create_response = jira.create_issue(project: 'PROJKEY', type: 'Bug', summary: 'This is a new issue')
  puts "Issue created: #{create_response}"
rescue Exception => e
  puts "Jira CLI returned an error: #{e}"
end
```

Most methods will simply return the response from the cli as a `String`. If the cli command returns an error (i.e. the process writes to standard error), an exception is raised.

There are a handful of CLI actions that have a response in CSV format (such as listing issues or projects).  You can optionally have `jira_cli` convert the csv response into a hashe by passing `parse_response: true`. E.g.,

```ruby
jira.get_issue_list(jql: 'project=DELETEME', parse_response: true).each do |issue_id, issue_details|
  puts "Issue ID: #{issue_id}"
  puts "Issue attributes: #{issue_details}"
end
```

The methods that currently support the `parse_response` argument are:

|Method Name|
|---|
|`get_attachment_list`|               
|`get_comment_list`|                  
|`get_component_list`|                
|`get_issue_list`|                    
|`get_issue_type_list`|               
|`get_issue_type_screen_scheme_list`|
|`get_issue_type_scheme_list`|        
|`get_link_list`|                     
|`get_screen_list`|                   
|`get_screen_scheme_list`|            
|`get_version_list`|                  
|`get_workflow_list`|                 
|`get_workflow_scheme_list`|    

### Advanced Configuration

By default `JiraCli::Wrapper.instance` will make system calls to the Bob Swift JIRA CLI with the assumption you have set up a shell script in your `PATH` which can be invoked in the format:

```
jira --action someCliAction --firstArgument "some value"
```

If your environment is not configured in this manner, you can alternatively configure the gem like this:

```ruby
JiraCli.setup do |config|
  config.cli_jar_path = '/path/to/jira-cli-6.7.0.jar'
  config.server_url   = 'http://jira.mywebsite.com'
  config.user         = 'my_username'
  config.password     = 'my_password'
end

jira = JiraCli::Wrapper.instance
```

With this configuration, if you were to call `jira.get_server_info` the system call that gets executed is:

```
java -jar "/path/to/jira-cli-6.7.0.jar" --server "http://jira.mywebsite.com" --user "my_username" --password "my_password" --action "getServerInfo"
```

## Further Examples

The following examples are based on the examples documented in Bob Swift's CLI project: [Examples](https://bobswift.atlassian.net/wiki/display/JCLI/Examples)

|Bob Swift's CLI Example|`jira_cli` equivalent|
|---|---|
|`jira --action "addAttachment" --issue "ZATTACH-1" --file "-" --name "dataFromStandardInput.txt" --findReplace "xxx:yyy"`|`jira.add_attachment(issue: "ZATTACH-1", file: "-", name: "dataFromStandardInput.txt", find_replace: "xxx:yyy")`|
|`jira --action "addAttachment" --issue "ZATTACH-1" --file "src/itest/resources/binary.bin" --verbose`|`jira.add_attachment(issue: "ZATTACH-1", file: "src/itest/resources/binary.bin", verbose: true)`|
|`jira --action "addAttachment" --issue "ZATTACH-1" --file "src/itest/resources/data.txt" --findReplace "xxx:yyy" --verbose`|`jira.add_attachment(issue: "ZATTACH-1", file: "src/itest/resources/data.txt", find_replace: "xxx:yyy", verbose: true)`|
|`jira --action "addAttachment" --issue "ZATTACH-1" --file "src/itest/resources/data.txt" --name "data"`|`jira.add_attachment(issue: "ZATTACH-1", file: "src/itest/resources/data.txt", name: "data")`|
|`jira --action "addAttachment" --issue "ZATTACH-1" --file "src/itest/resources/empty.txt"`|`jira.add_attachment(issue: "ZATTACH-1", file: "src/itest/resources/empty.txt")`|
|`jira --action "addAttachment" --issue "ZATTACH-1" --file "src/itest/resources/large.zip"`|`jira.add_attachment(issue: "ZATTACH-1", file: "src/itest/resources/large.zip")`|
|`jira --action "addAttachment" --issue "ZATTACH-1" --file "src/itest/resources/Special name #&?"`|`jira.add_attachment(issue: "ZATTACH-1", file: "src/itest/resources/Special name #&?")`|
|`jira --action "addAttachment" --issue "ZJIRACLI-3" --file "src/itest/resources/data.txt"`|`jira.add_attachment(issue: "ZJIRACLI-3", file: "src/itest/resources/data.txt")`|
|`jira --action "addAttachment" --issue "ZRUNNER-1" --file "src/itest/resources/data.txt"`|`jira.add_attachment(issue: "ZRUNNER-1", file: "src/itest/resources/data.txt")`|
|`jira --action "addComment" --issue "ZCLICLONE-1" --comment "my comment" --role "Developers"`|`jira.add_comment(issue: "ZCLICLONE-1", comment: "my comment", role: "Developers")`|
|`jira --action "addComment" --issue "ZCLICLONE-4" --comment "my comment"`|`jira.add_comment(issue: "ZCLICLONE-4", comment: "my comment")`|
|`jira --action "addComment" --issue "ZCLICLONE-4" --comment "my group restricted comment" --group "jira-users"`|`jira.add_comment(issue: "ZCLICLONE-4", comment: "my group restricted comment", group: "jira-users")`|
|`jira --action "addComment" --issue "ZCLICLONE-4" --comment "my role restricted comment" --role "Developers"`|`jira.add_comment(issue: "ZCLICLONE-4", comment: "my role restricted comment", role: "Developers")`|
|`jira --action "addComment" --issue "ZJIRACLI-3" --file "src/itest/resources/data.txt" --findReplace "xxx:yyy"`|`jira.add_comment(issue: "ZJIRACLI-3", file: "src/itest/resources/data.txt", find_replace: "xxx:yyy")`|
|`jira --action "addComponent" --project "ZCOMP" --name "C1" --lead "automation" --description "C1 description" --defaultAssignee "COMPONENT_LEAD"`|`jira.add_component(project: "ZCOMP", name: "C1", lead: "automation", description: "C1 description", default_assignee: "COMPONENT_LEAD")`|
|`jira --action "addComponent" --project "ZCOMP" --name "C2" --lead "automation" --description "C2 description" --defaultAssignee "COMPONENT_LEAD"`|`jira.add_component(project: "ZCOMP", name: "C2", lead: "automation", description: "C2 description", default_assignee: "COMPONENT_LEAD")`|
|`jira --action "addComponent" --project "ZEXPORT2" --name "C1" --description "C1 description"`|`jira.add_component(project: "ZEXPORT2", name: "C1", description: "C1 description")`|
|`jira --action "addComponent" --project "zjiracli" --name "C1" --description "a generic description"`|`jira.add_component(project: "zjiracli", name: "C1", description: "a generic description")`|
|`jira --action "addComponent" --project "zjiracli" --name "C1" --description "a generic description" --replace`|`jira.add_component(project: "zjiracli", name: "C1", description: "a generic description", replace: true)`|
|`jira --action "addComponent" --project "zjiracli" --name "C2" --lead "developer" --description "a generic description" --defaultAssignee "COMPONENT_LEAD"`|`jira.add_component(project: "zjiracli", name: "C2", lead: "developer", description: "a generic description", default_assignee: "COMPONENT_LEAD")`|
|`jira --action "addComponent" --project "zjiracli" --name "swap2" --description "a generic description"`|`jira.add_component(project: "zjiracli", name: "swap2", description: "a generic description")`|
|`jira --action "addCustomField" --field "zzz_Number Field" --type "com.atlassian.jira.plugin.system.customfieldtypes:float" --continue --jql "com.atlassian.jira.plugin.system.customfieldtypes:exactnumber"`|`jira.add_custom_field(field: "zzz_Number Field", type: "com.atlassian.jira.plugin.system.customfieldtypes:float", continue: true, jql: "com.atlassian.jira.plugin.system.customfieldtypes:exactnumber")`|
|`jira --action "addCustomField" --field "zzz_Radio Buttons" --type "com.atlassian.jira.plugin.system.customfieldtypes:radiobuttons" --continue`|`jira.add_custom_field(field: "zzz_Radio Buttons", type: "com.atlassian.jira.plugin.system.customfieldtypes:radiobuttons", continue: true)`|
|`jira --action "addCustomField" --field "zzz_Select List (single choice)" --type "com.atlassian.jira.plugin.system.customfieldtypes:multiselect" --continue`|`jira.add_custom_field(field: "zzz_Select List (single choice)", type: "com.atlassian.jira.plugin.system.customfieldtypes:multiselect", continue: true)`|
|`jira --action "addGroup" --group "Testgroup1" --preserveCase`|`jira.add_group(group: "Testgroup1", preserve_case: true)`|
|`jira --action "addLabels" --issue "ZJIRACLI-8" --labels "addLabel1 addLabel2"`|`jira.add_labels(issue: "ZJIRACLI-8", labels: "addLabel1 addLabel2")`|
|`jira --action "addProjectRoleActors" --project "zjiracli" --role "users" --userId "user, admin"`|`jira.add_project_role_actors(project: "zjiracli", role: "users", user_id: "user, admin")`|
|`jira --action "addProjectRoleActors" --project "ZROLES" --role "administrators" --userId "project-admin"`|`jira.add_project_role_actors(project: "ZROLES", role: "administrators", user_id: "project-admin")`|
|`jira --action "addProjectRoleActors" --project "ZROLES" --role "users" --userId "user, admin"`|`jira.add_project_role_actors(project: "ZROLES", role: "users", user_id: "user, admin")`|
|`jira --action "addProjectRole" --name "zAdd project role test" --description "addProjectRole test"`|`jira.add_project_role(name: "zAdd project role test", description: "addProjectRole test")`|
|`jira --action "addRemoteLink" --issue "ZLINKS-1" --name "addRemoteLinkUrl" --url "https://google.com"`|`jira.add_remote_link(issue: "ZLINKS-1", name: "addRemoteLinkUrl", url: "https://google.com")`|
|`jira --action "addTransition" --workflow "zjiracliworkflow_new" --name "test 1" --description "Transition for testing" --step "1"`|`jira.add_transition(workflow: "zjiracliworkflow_new", name: "test 1", description: "Transition for testing", step: "1")`|
|`jira --action "addTransition" --workflow "zjiracliworkflow_new" --name "test 2" --description "Transition for testing" --step "1" --transition "3" --screen "Default Screen"`|`jira.add_transition(workflow: "zjiracliworkflow_new", name: "test 2", description: "Transition for testing", step: "1", transition: "3", screen: "Default Screen")`|
|`jira --action "addTransition" --workflow "zjiracliworkflow_new" --name "test 3" --description "Transition for testing" --step "1" --screen "12326"`|`jira.add_transition(workflow: "zjiracliworkflow_new", name: "test 3", description: "Transition for testing", step: "1", screen: "12326")`|
|`jira --action "addTransition" --workflow "zjiracliworkflow_new" --name "test 4" --description "Transition for testing" --step "1" --screen "FIELDCONF: Software Development Default Issue Screen"`|`jira.add_transition(workflow: "zjiracliworkflow_new", name: "test 4", description: "Transition for testing", step: "1", screen: "FIELDCONF: Software Development Default Issue Screen")`|
|`jira --action "addTransition" --workflow "zjiracliworkflow_new" --name "test 9" --description "Transition for testing" --step "3"`|`jira.add_transition(workflow: "zjiracliworkflow_new", name: "test 9", description: "Transition for testing", step: "3")`|
|`jira --action "addUserToGroup" --userId "Testuser3" --group "testgroup2" --autoGroup`|`jira.add_user_to_group(user_id: "Testuser3", group: "testgroup2", auto_group: true)`|
|`jira --action "addUser" --userId "automation" --userEmail "testuser@x.com"`|`jira.add_user(user_id: "automation", user_email: "testuser@x.com")`|
|`jira --action "addUser" --userId "testuser1" --userFullName "Test User1" --userEmail "testuser1@x.com" --userPassword ""`|`jira.add_user(user_id: "testuser1", user_full_name: "Test User1", user_email: "testuser1@x.com", user_password: "")`|
|`jira --action "addUser" --userId "testuser2" --userFullName "Special User 2" --userEmail "testuser2@x.com"`|`jira.add_user(user_id: "testuser2", user_full_name: "Special User 2", user_email: "testuser2@x.com")`|
|`jira --action "addUser" --userId "Testuser3" --userEmail "testuser3@x.com" --preserveCase`|`jira.add_user(user_id: "Testuser3", user_email: "testuser3@x.com", preserve_case: true)`|
|`jira --action "addVersion" --project "ZEXPORT2" --name "V1" --description "V1 description"`|`jira.add_version(project: "ZEXPORT2", name: "V1", description: "V1 description")`|
|`jira --action "addVersion" --project "zjiracli for automated testing" --name "V2" --date "5/30/15" --startDate "9/30/14" --after "V1" --description "V2 description"`|`jira.add_version(project: "zjiracli for automated testing", name: "V2", date: "5/30/15", start_date: "9/30/14", after: "V1", description: "V2 description")`|
|`jira --action "addVersion" --project "zjiracli for automated testing" --name "With Blanks"`|`jira.add_version(project: "zjiracli for automated testing", name: "With Blanks")`|
|`jira --action "addVersion" --project "zjiracli" --name "V1"`|`jira.add_version(project: "zjiracli", name: "V1")`|
|`jira --action "addVersion" --project "zjiracli" --version "V2" --date "5/30/15" --description "V2 description" --replace`|`jira.add_version(project: "zjiracli", version: "V2", date: "5/30/15", description: "V2 description", replace: true)`|
|`jira --action "addVersion" --project "ZRUNNER" --name "V1"`|`jira.add_version(project: "ZRUNNER", name: "V1")`|
|`jira --action "addVersion" --project "ZRUNNER" --name "V2"`|`jira.add_version(project: "ZRUNNER", name: "V2")`|
|`jira --action "addVote" --issue "ZVOTEWATCH-1" --user "developer" --password "asDeVqeTwsjtr4GnyKwf"`|`jira.add_vote(issue: "ZVOTEWATCH-1", user: "developer", password: "asDeVqeTwsjtr4GnyKwf")`|
|`jira --action "addWatchers" --issue "ZCLICLONE-4" --userId "user, developer"`|`jira.add_watchers(issue: "ZCLICLONE-4", user_id: "user, developer")`|
|`jira --action "addWatchers" --issue "ZSUB-1" --userId "admin, developer"`|`jira.add_watchers(issue: "ZSUB-1", user_id: "admin, developer")`|
|`jira --action "addWatchers" --issue "ZVOTEWATCH-1" --userId "invalid1, invalid2" --continue`|`jira.add_watchers(issue: "ZVOTEWATCH-1", user_id: "invalid1, invalid2", continue: true)`|
|`jira --action "addWatchers" --issue "ZVOTEWATCH-1" --userId "user, developer"`|`jira.add_watchers(issue: "ZVOTEWATCH-1", user_id: "user, developer")`|
|`jira --action "addWork" --issue "ZCLICLONE-4" --timeSpent "1h" --autoAdjust`|`jira.add_work(issue: "ZCLICLONE-4", time_spent: "1h", auto_adjust: true)`|
|`jira --action "addWork" --issue "ZWORK-1" --timeSpent "1d 1h" --date "1/02/11 9:00 a"`|`jira.add_work(issue: "ZWORK-1", time_spent: "1d 1h", date: "1/02/11 9:00 a")`|
|`jira --action "addWork" --issue "ZWORK-1" --timeSpent "3h 30m" --comment "My work log entry" --role "Developers" --group "jira-users"`|`jira.add_work(issue: "ZWORK-1", time_spent: "3h 30m", comment: "My work log entry", role: "Developers", group: "jira-users")`|
|`jira --action "addWork" --issue "ZWORK-1" --timeSpent "3h 30m" --date "2011-01-01" --dateFormat "yyyy-MM-dd" --group "jira-users"`|`jira.add_work(issue: "ZWORK-1", time_spent: "3h 30m", date: "2011-01-01", date_format: "yyyy-MM-dd", group: "jira-users")`|
|`jira --action "addWork" --issue "ZWORK-1" --timeSpent "3h 30m" --estimate "3w"`|`jira.add_work(issue: "ZWORK-1", time_spent: "3h 30m", estimate: "3w")`|
|`jira --action "addWork" --issue "ZWORK-1" --timeSpent "3m" --date "2011-01-01"`|`jira.add_work(issue: "ZWORK-1", time_spent: "3m", date: "2011-01-01")`|
|`jira --action "addWork" --issue "ZWORK-1" --timeSpent "3m" --date "2011-01-01 22:33:01"`|`jira.add_work(issue: "ZWORK-1", time_spent: "3m", date: "2011-01-01 22:33:01")`|
|`jira --action "addWork" --issue "ZWORK-1" --timeSpent "5" --userId "developer"`|`jira.add_work(issue: "ZWORK-1", time_spent: "5", user_id: "developer")`|
|`jira --action "addWork" --issue "ZWORK-2" --timeSpent "2h"`|`jira.add_work(issue: "ZWORK-2", time_spent: "2h")`|
|`jira --action "archiveVersion" --project "zjiracli" --version "V1"`|`jira.archive_version(project: "zjiracli", version: "V1")`|
|`jira --action "assignIssue" --issue "ZJIRACLI-5" --userId ""`|`jira.assign_issue(issue: "ZJIRACLI-5", user_id: "")`|
|`jira --action "assignIssue" --issue "ZJIRACLI-5" --userId "automation"`|`jira.assign_issue(issue: "ZJIRACLI-5", user_id: "automation")`|
|`jira --action "assignIssue" --issue "ZJIRACLI-5" --userId "@default"`|`jira.assign_issue(issue: "ZJIRACLI-5", user_id: "@default")`|
|`jira --action "cloneIssue" --issue "ZATTACH-1" --copyAttachments`|`jira.clone_issue(issue: "ZATTACH-1", copy_attachments: true)`|
|`jira --action "cloneIssue" --issue "ZCLICLONE-3"`|`jira.clone_issue(issue: "ZCLICLONE-3")`|
|`jira --action "cloneIssue" --issue "ZCLICLONE-4" --parent "ZCLICLONE-2" --copySubtaskEstimates --copyLinks --copyWatchers --copyComments --useParentVersions --fieldExcludes "custom-multi-select,custom three" --quiet`|`jira.clone_issue(issue: "ZCLICLONE-4", parent: "ZCLICLONE-2", copy_subtask_estimates: true, copy_links: true, copy_watchers: true, copy_comments: true, use_parent_versions: true, field_excludes: "custom-multi-select,custom three", quiet: true)`|
|`jira --action "cloneIssue" --issue "ZJIRACLI-3" --description "clone description"`|`jira.clone_issue(issue: "ZJIRACLI-3", description: "clone description")`|
|`jira --action "cloneIssue" --issue "ZJIRACLI-3" --summary "clone summary" --comment "comment for cloned issue"`|`jira.clone_issue(issue: "ZJIRACLI-3", summary: "clone summary", comment: "comment for cloned issue")`|
|`jira --action "cloneIssue" --issue "ZJIRACLI-3" --summary "clone summary" --date "2013-12-30" --dateFormat "yyyy-MM-dd"`|`jira.clone_issue(issue: "ZJIRACLI-3", summary: "clone summary", date: "2013-12-30", date_format: "yyyy-MM-dd")`|
|`jira --action "cloneIssue" --issue "ZLINKS-1" --summary "cloneThis is content." --link "Cloners"`|`jira.clone_issue(issue: "ZLINKS-1", summary: "cloneThis is content.", link: "Cloners")`|
|`jira --action "cloneIssue" --project "ZCLICLONE" --issue "ZCLICLONE-1"`|`jira.clone_issue(project: "ZCLICLONE", issue: "ZCLICLONE-1")`|
|`jira --action "cloneIssue" --project "ZCLICLONE" --issue "ZCLICLONE-1" --copyLinks`|`jira.clone_issue(project: "ZCLICLONE", issue: "ZCLICLONE-1", copy_links: true)`|
|`jira --action "cloneIssue" --project "ZCLICLONEX" --issue "ZCLICLONE-1" --copySubtaskEstimates --copyLinks --copyWatchers --copyComments`|`jira.clone_issue(project: "ZCLICLONEX", issue: "ZCLICLONE-1", copy_subtask_estimates: true, copy_links: true, copy_watchers: true, copy_comments: true)`|
|`jira --action "cloneIssues" --copyAttachments --copySubtasks --jql "key = ZATTACH-1"`|`jira.clone_issues(copy_attachments: true, copy_subtasks: true, jql: "key = ZATTACH-1")`|
|`jira --action "cloneIssues" --jql "issue = ZCLICLONE-1" --copySubtasks`|`jira.clone_issues(jql: "issue = ZCLICLONE-1", copy_subtasks: true)`|
|`jira --action "cloneIssues" --project "ZCLICLONEX" --jql "project = ZCLICLONE and issuetype = bug" --autoVersion --autoComponent`|`jira.clone_issues(project: "ZCLICLONEX", jql: "project = ZCLICLONE and issuetype = bug", auto_version: true, auto_component: true)`|
|`jira --action "cloneIssues" --project "ZCLICLONEX" --type "improvement" --jql "project = ZCLICLONE and issuetype = bug"`|`jira.clone_issues(project: "ZCLICLONEX", type: "improvement", jql: "project = ZCLICLONE and issuetype = bug")`|
|`jira --action "cloneIssues" --project "zjiracliA" --jql "project = zjiracli and issuetype = bug"`|`jira.clone_issues(project: "zjiracliA", jql: "project = zjiracli and issuetype = bug")`|
|`jira --action "cloneIssues" --project "zjiracliA" --type "improvement" --jql "project = zjiracli and issuetype = bug"`|`jira.clone_issues(project: "zjiracliA", type: "improvement", jql: "project = zjiracli and issuetype = bug")`|
|`jira --action "cloneIssues" --toProject "ZRUNNERC" --description "Bulk clone example" --search 'project = ZRUNNER and summary ~ "volume-*"'`|`jira.clone_issues(to_project: "ZRUNNERC", description: "Bulk clone example", search: "project = ZRUNNER and summary ~ \"volume-*\"")`|
|`jira --action "cloneIssues" --type "task" --jql "project = ZCLICLONE and issuetype = bug"`|`jira.clone_issues(type: "task", jql: "project = ZCLICLONE and issuetype = bug")`|
|`jira --action "cloneIssues" --type "task" --jql "project = zjiracli and issuetype = bug"`|`jira.clone_issues(type: "task", jql: "project = zjiracli and issuetype = bug")`|
|`jira --action "cloneProject" --project "Template" --toProject "zjiracli" --lead "automation" --name "zjiracli for automated testing" --defaultAssignee "unassigned"`|`jira.clone_project(project: "Template", to_project: "zjiracli", lead: "automation", name: "zjiracli for automated testing", default_assignee: "unassigned")`|
|`jira --action "cloneProject" --project "ZAGILE" --toProject "ZAGILEC" --cloneIssues`|`jira.clone_project(project: "ZAGILE", to_project: "ZAGILEC", clone_issues: true)`|
|`jira --action "cloneProject" --project "ZATTACH" --toProject "ZATTACH2" --cloneIssues --copyAttachments --copySubtasks`|`jira.clone_project(project: "ZATTACH", to_project: "ZATTACH2", clone_issues: true, copy_attachments: true, copy_subtasks: true)`|
|`jira --action "cloneProject" --project "ZCLICLONEB" --issueTypeScheme "Default Issue Type Scheme" --issueTypeScreenScheme "Default Issue Type Screen Scheme" --permissionScheme "Default Permission Scheme" --toProject "ZCLICLONEY"`|`jira.clone_project(project: "ZCLICLONEB", issue_type_scheme: "Default Issue Type Scheme", issue_type_screen_scheme: "Default Issue Type Screen Scheme", permission_scheme: "Default Permission Scheme", to_project: "ZCLICLONEY")`|
|`jira --action "cloneProject" --project "ZCLICLONE" --issueTypeScheme "Default Issue Type Scheme" --issueTypeScreenScheme "Default Issue Type Screen Scheme" --permissionScheme "Default Permission Scheme" --toProject "ZCLICLONEX"`|`jira.clone_project(project: "ZCLICLONE", issue_type_scheme: "Default Issue Type Scheme", issue_type_screen_scheme: "Default Issue Type Screen Scheme", permission_scheme: "Default Permission Scheme", to_project: "ZCLICLONEX")`|
|`jira --action "cloneProject" --project "ZCLICLONES" --issueTypeScheme "Default Issue Type Scheme" --issueTypeScreenScheme "Default Issue Type Screen Scheme" --permissionScheme "Default Permission Scheme" --toProject "ZCLICLONET"`|`jira.clone_project(project: "ZCLICLONES", issue_type_scheme: "Default Issue Type Scheme", issue_type_screen_scheme: "Default Issue Type Screen Scheme", permission_scheme: "Default Permission Scheme", to_project: "ZCLICLONET")`|
|`jira --action "cloneProject" --project "zjiracliC" --toProject "zjiracliD"`|`jira.clone_project(project: "zjiracliC", to_project: "zjiracliD")`|
|`jira --action "cloneProject" --project "zjiracli" --jql "type = 'bug'" --toProject "zjiracliB" --issueSecurityScheme "test restrictions" --copyVersions --copyComponents --copyRoleActors --cloneIssues --copyAttachments --copySubtasks --continue`|`jira.clone_project(project: "zjiracli", jql: "type = 'bug'", to_project: "zjiracliB", issue_security_scheme: "test restrictions", copy_versions: true, copy_components: true, copy_role_actors: true, clone_issues: true, copy_attachments: true, copy_subtasks: true, continue: true)`|
|`jira --action "cloneProject" --project "zjiracli" --toProject "zjiracliA" --name "ZcloneNameA"`|`jira.clone_project(project: "zjiracli", to_project: "zjiracliA", name: "ZcloneNameA")`|
|`jira --action "cloneProject" --project "zjiracli" --toProject "zjiracliC" --cloneIssues --jql "issuetype = bug" --autoVersion --debug`|`jira.clone_project(project: "zjiracli", to_project: "zjiracliC", clone_issues: true, jql: "issuetype = bug", auto_version: true, debug: true)`|
|`jira --action "copyAttachments" --issue "ZATTACH-1" --toIssue "ZATTACH-2"`|`jira.copy_attachments(issue: "ZATTACH-1", to_issue: "ZATTACH-2")`|
|`jira --action "copyAttachments" --issue "ZATTACH-1" --toIssue "ZATTACH-3" --name "data.txt"`|`jira.copy_attachments(issue: "ZATTACH-1", to_issue: "ZATTACH-3", name: "data.txt")`|
|`jira --action "copyComponent" --project "ZCOMP" --toProject "ZCOMP2" --component "C1"`|`jira.copy_component(project: "ZCOMP", to_project: "ZCOMP2", component: "C1")`|
|`jira --action "copyComponent" --project "zjiracli" --component "C1" --name "C3First" --description "override description"`|`jira.copy_component(project: "zjiracli", component: "C1", name: "C3First", description: "override description")`|
|`jira --action "copyComponents" --project "ZCOMP" --toProject "ZCOMP2" --replace`|`jira.copy_components(project: "ZCOMP", to_project: "ZCOMP2", replace: true)`|
|`jira --action "copyComponents" --project "zjiracli" --toProject "zjiracliX"`|`jira.copy_components(project: "zjiracli", to_project: "zjiracliX")`|
|`jira --action "copyComponents" --project "zjiracli" --toProject "zjiracliX" --components "C1, C2" --replace`|`jira.copy_components(project: "zjiracli", to_project: "zjiracliX", components: "C1, C2", replace: true)`|
|`jira --action "copyFieldValue" --issue "ZJIRACLI-10" --field "custom1" --field2 "custom-versions" --asVersion --autoVersion`|`jira.copy_field_value(issue: "ZJIRACLI-10", field: "custom1", field2: "custom-versions", as_version: true, auto_version: true)`|
|`jira --action "copyFieldValue" --issue "ZJIRACLI-10" --toIssue "ZJIRACLI-11" --field "custom1"`|`jira.copy_field_value(issue: "ZJIRACLI-10", to_issue: "ZJIRACLI-11", field: "custom1")`|
|`jira --action "copyFieldValue" --issue "ZJIRACLI-10" --toIssue "ZJIRACLI-11" --field "fixVersions" --field2 "custom-versions" --asVersion`|`jira.copy_field_value(issue: "ZJIRACLI-10", to_issue: "ZJIRACLI-11", field: "fixVersions", field2: "custom-versions", as_version: true)`|
|`jira --action "copyFieldValue" --issue "ZJIRACLI-10" --toIssue "ZJIRACLI-11" --field "summary" --field2 "custom2"`|`jira.copy_field_value(issue: "ZJIRACLI-10", to_issue: "ZJIRACLI-11", field: "summary", field2: "custom2")`|
|`jira --action "copyProjectRoleActors" --project "ZROLES" --toProject "ZROLESX"`|`jira.copy_project_role_actors(project: "ZROLES", to_project: "ZROLESX")`|
|`jira --action "copyVersion" --project "zjiracliA" --version "V1" --name "newV1"`|`jira.copy_version(project: "zjiracliA", version: "V1", name: "newV1")`|
|`jira --action "copyVersion" --project "zjiracli" --toProject "zjiracliA" --name "V1"`|`jira.copy_version(project: "zjiracli", to_project: "zjiracliA", name: "V1")`|
|`jira --action "copyVersion" --project "zjiracli" --toProject "zjiracliA" --name "V2" --after "-1"`|`jira.copy_version(project: "zjiracli", to_project: "zjiracliA", name: "V2", after: "-1")`|
|`jira --action "copyVersion" --project "zjiracli" --toProject "zjiracliA" --version "V1" --description "replaced description" --startDate "9/30/14" --replace`|`jira.copy_version(project: "zjiracli", to_project: "zjiracliA", version: "V1", description: "replaced description", start_date: "9/30/14", replace: true)`|
|`jira --action "copyVersions" --project "zjiracli" --toProject "zjiracliC" --replace`|`jira.copy_versions(project: "zjiracli", to_project: "zjiracliC", replace: true)`|
|`jira --action "copyWorkflow" --workflow "jira" --name "zjiracliworkflow_new" --description "Copy of jira for jiracliworkflow test"`|`jira.copy_workflow(workflow: "jira", name: "zjiracliworkflow_new", description: "Copy of jira for jiracliworkflow test")`|
|`jira --action "createBoard" --name "ZAGILE" --type "kanban" --project "ZAGILE"`|`jira.create_board(name: "ZAGILE", type: "kanban", project: "ZAGILE")`|
|`jira --action "createBoard" --name "ZAGILE" --type "scrum" --project "ZAGILE"`|`jira.create_board(name: "ZAGILE", type: "scrum", project: "ZAGILE")`|
|`jira --action "createFilter" --name "ZFILTER2" --description "ZFILTER2 description" --jql "project = ZFILTER" --favorite`|`jira.create_filter(name: "ZFILTER2", description: "ZFILTER2 description", jql: "project = ZFILTER", favorite: true)`|
|`jira --action "createIssue" --parent "ZSUB-1" --type "Sub-task" --summary "subtask2: %parent_summary%"`|`jira.create_issue(parent: "ZSUB-1", type: "Sub-task", summary: "subtask2: %parent_summary%")`|
|`jira --action "createIssue" --project "ZAGILE" --type "Epic" --summary "Epic issue" --field "Epic Name" --value "Epic1"`|`jira.create_issue(project: "ZAGILE", type: "Epic", summary: "Epic issue", field: "Epic Name", value: "Epic1")`|
|`jira --action "createIssue" --project "ZAGILE" --type "Story" --summary "Story issue" --field "Epic Link" --value "ZAGILE-1"`|`jira.create_issue(project: "ZAGILE", type: "Story", summary: "Story issue", field: "Epic Link", value: "ZAGILE-1")`|
|`jira --action "createIssue" --project "ZATTACH" --type "bug" --summary "Copy attachments target"`|`jira.create_issue(project: "ZATTACH", type: "bug", summary: "Copy attachments target")`|
|`jira --action "createIssue" --project "ZATTACH" --type "bug" --summary "For attachments"`|`jira.create_issue(project: "ZATTACH", type: "bug", summary: "For attachments")`|
|`jira --action "createIssue" --project "ZATTACH" --type "Sub-task" --parent "ZATTACH-1" --summary "Subtask with attachments"`|`jira.create_issue(project: "ZATTACH", type: "Sub-task", parent: "ZATTACH-1", summary: "Subtask with attachments")`|
|`jira --action "createIssue" --project "ZCLICLONE" --parent "ZCLICLONE-1" --summary "Subtask 1" --type "Sub-task"`|`jira.create_issue(project: "ZCLICLONE", parent: "ZCLICLONE-1", summary: "Subtask 1", type: "Sub-task")`|
|`jira --action "createIssue" --project "ZCLICLONE" --parent "ZCLICLONE-1" --summary "Subtask 2" --type "Sub-task2" --originalEstimate "1d" --custom "testcase1:xxx,custom three:333"`|`jira.create_issue(project: "ZCLICLONE", parent: "ZCLICLONE-1", summary: "Subtask 2", type: "Sub-task2", original_estimate: "1d", custom: "testcase1:xxx,custom three:333")`|
|`jira --action "createIssue" --project "ZCLICLONE" --type "bug" --summary "Summary" --affectsVersions "V1" --fixVersions "V1,V2" --components "C2,C1" --field "custom-versions" --values "V2, V1" --autoVersion --autoComponent --field2 "custom-user-picker" --values2 "automation"`|`jira.create_issue(project: "ZCLICLONE", type: "bug", summary: "Summary", affects_versions: "V1", fix_versions: "V1,V2", components: "C2,C1", field: "custom-versions", values: "V2, V1", auto_version: true, auto_component: true, field2: "custom-user-picker", values2: "automation")`|
|`jira --action "createIssue" --project "ZCOMP" --type "bug" --summary "test" --components "auto1,auto2" --autoComponent`|`jira.create_issue(project: "ZCOMP", type: "bug", summary: "test", components: "auto1,auto2", auto_component: true)`|
|`jira --action "createIssue" --project "zcustom" --type "bug" --summary "cascade issue" --custom "custom1:xxxx" --field "custom-cascade-select" --values "1,A" --asCascadeSelect`|`jira.create_issue(project: "zcustom", type: "bug", summary: "cascade issue", custom: "custom1:xxxx", field: "custom-cascade-select", values: "1,A", as_cascade_select: true)`|
|`jira --action "createIssue" --project "zcustom" --type "bug" --summary "cascade issue" --custom "custom1:xxxx" --field "custom-cascade-select" --values "1,A" --field2 "custom-multi-select" --values2 "s1" --asCascadeSelect`|`jira.create_issue(project: "zcustom", type: "bug", summary: "cascade issue", custom: "custom1:xxxx", field: "custom-cascade-select", values: "1,A", field2: "custom-multi-select", values2: "s1", as_cascade_select: true)`|
|`jira --action "createIssue" --project "zcustom" --type "bug" --summary "cascade issue" --field "custom-cascade-select" --values "1,A" --asCascadeSelect`|`jira.create_issue(project: "zcustom", type: "bug", summary: "cascade issue", field: "custom-cascade-select", values: "1,A", as_cascade_select: true)`|
|`jira --action "createIssue" --project "zcustom" --type "bug" --summary "checkbox" --field "custom-multi-checkbox" --values "check1,check2"`|`jira.create_issue(project: "zcustom", type: "bug", summary: "checkbox", field: "custom-multi-checkbox", values: "check1,check2")`|
|`jira --action "createIssue" --project "zcustom" --type "story" --summary "mutli issue" --field "custom-multi-select" --values "s1,s2,s3" --field2 "testcase2" --values2 "No" --custom "testcase1:zzzzzzzzzz,Story Points:99.1"`|`jira.create_issue(project: "zcustom", type: "story", summary: "mutli issue", field: "custom-multi-select", values: "s1,s2,s3", field2: "testcase2", values2: "No", custom: "testcase1:zzzzzzzzzz,Story Points:99.1")`|
|`jira --action "createIssue" --project "ZFIELDS" --file "src/itest/resources/data.txt" --type "Bug" --summary "original summary" --assignee "automation" --environment "original environment" --fixVersions "V1,V2" --components "C1" --autoVersion --autoComponent`|`jira.create_issue(project: "ZFIELDS", file: "src/itest/resources/data.txt", type: "Bug", summary: "original summary", assignee: "automation", environment: "original environment", fix_versions: "V1,V2", components: "C1", auto_version: true, auto_component: true)`|
|`jira --action "createIssue" --project "ZFIELDS" --file "src/itest/resources/data.txt" --type "Bug" --summary "This is content." --assignee "automation" --environment "x12345"`|`jira.create_issue(project: "ZFIELDS", file: "src/itest/resources/data.txt", type: "Bug", summary: "This is content.", assignee: "automation", environment: "x12345")`|
|`jira --action "createIssue" --project "ZFIELDS" --type "Sub-task" --summary "This is content." --parent "ZFIELDS-1"`|`jira.create_issue(project: "ZFIELDS", type: "Sub-task", summary: "This is content.", parent: "ZFIELDS-1")`|
|`jira --action "createIssue" --project "ZHISTORY" --type "task" --summary "Initial summary"`|`jira.create_issue(project: "ZHISTORY", type: "task", summary: "Initial summary")`|
|`jira --action "createIssue" --project "zjiracliB" --type "bug" --summary "secured issue" --security "developer-role"`|`jira.create_issue(project: "zjiracliB", type: "bug", summary: "secured issue", security: "developer-role")`|
|`jira --action "createIssue" --project "zjiracli" --file "src/itest/resources/data.txt" --type "Bug" --summary "This is content." --assignee "automation" --lookup --date "" --field "custom-multi-select" --values "s1,s2,s3" --originalEstimate "20m"`|`jira.create_issue(project: "zjiracli", file: "src/itest/resources/data.txt", type: "Bug", summary: "This is content.", assignee: "automation", lookup: true, date: "", field: "custom-multi-select", values: "s1,s2,s3", original_estimate: "20m")`|
|`jira --action "createIssue" --project "zjiracli" --file "target/output/jiracli/createIssueLongDescription.txt" --type "task" --summary "Long description"`|`jira.create_issue(project: "zjiracli", file: "target/output/jiracli/createIssueLongDescription.txt", type: "task", summary: "Long description")`|
|`jira --action "createIssue" --project "zjiracli for automated testing" --type "task" --summary "This is content." --assignee "automation" --comment "Added after create"`|`jira.create_issue(project: "zjiracli for automated testing", type: "task", summary: "This is content.", assignee: "automation", comment: "Added after create")`|
|`jira --action "createIssue" --project "zjiracli" --type "Bug" --summary "This is content." --labels "label1"`|`jira.create_issue(project: "zjiracli", type: "Bug", summary: "This is content.", labels: "label1")`|
|`jira --action "createIssue" --project "zjiracli" --type "Bug" --summary "This is content." --labels "xxx"`|`jira.create_issue(project: "zjiracli", type: "Bug", summary: "This is content.", labels: "xxx")`|
|`jira --action "createIssue" --project "zjiracli" --type "Sub-task" --summary "This is content." --parent "ZJIRACLI-1"`|`jira.create_issue(project: "zjiracli", type: "Sub-task", summary: "This is content.", parent: "ZJIRACLI-1")`|
|`jira --action "createIssue" --project "zjiracli" --type "task" --summary "This is content."`|`jira.create_issue(project: "zjiracli", type: "task", summary: "This is content.")`|
|`jira --action "createIssue" --project "zjiracli" --type "task" --summary "This is content." --field "custom1" --values "V1copy" --fixVersions "V1"`|`jira.create_issue(project: "zjiracli", type: "task", summary: "This is content.", field: "custom1", values: "V1copy", fix_versions: "V1")`|
|`jira --action "createIssue" --project "zjiracliX" --type "bug" --summary "This is content."`|`jira.create_issue(project: "zjiracliX", type: "bug", summary: "This is content.")`|
|`jira --action "createIssue" --project "zjiracliX" --type "Bug" --summary "This is content." --description "a generic description"`|`jira.create_issue(project: "zjiracliX", type: "Bug", summary: "This is content.", description: "a generic description")`|
|`jira --action "createIssue" --project "zlinks" --type "Bug" --summary "This is content."`|`jira.create_issue(project: "zlinks", type: "Bug", summary: "This is content.")`|
|`jira --action "createIssue" --project "zlinks" --type "Sub-task" --summary "This is content." --parent "ZLINKS-1"`|`jira.create_issue(project: "zlinks", type: "Sub-task", summary: "This is content.", parent: "ZLINKS-1")`|
|`jira --action "createIssue" --project "ZRUNNER" --type "Bug" --summary "This is content"`|`jira.create_issue(project: "ZRUNNER", type: "Bug", summary: "This is content")`|
|`jira --action "createIssue" --project "ZSUB" --type "bug" --summary "Summary"`|`jira.create_issue(project: "ZSUB", type: "bug", summary: "Summary")`|
|`jira --action "createIssue" --project "ZSUB" --type "bug" --summary "Summary" --description "Description" --environment "Environment" --affectsVersions "V1" --fixVersions "V1,V2" --components "C1,C2" --autoVersion --autoComponent --assignee "automation" --labels "label1 label2" --security "developer-role" --field "custom1" --value "Custom1" --field2 "custom2" --values2 "Custom2"`|`jira.create_issue(project: "ZSUB", type: "bug", summary: "Summary", description: "Description", environment: "Environment", affects_versions: "V1", fix_versions: "V1,V2", components: "C1,C2", auto_version: true, auto_component: true, assignee: "automation", labels: "label1 label2", security: "developer-role", field: "custom1", value: "Custom1", field2: "custom2", values2: "Custom2")`|
|`jira --action "createIssue" --project "ZSUPPORT" --type "bug" --priority "Major" --summary "Summary"`|`jira.create_issue(project: "ZSUPPORT", type: "bug", priority: "Major", summary: "Summary")`|
|`jira --action "createIssue" --project "zuser" --type "Bug" --summary "This is content" --assignee "automation"`|`jira.create_issue(project: "zuser", type: "Bug", summary: "This is content", assignee: "automation")`|
|`jira --action "createIssue" --project "zvotewatch" --type "Bug" --summary "summary text"`|`jira.create_issue(project: "zvotewatch", type: "Bug", summary: "summary text")`|
|`jira --action "createIssue" --project "zwork" --type "Bug" --summary "This is content"`|`jira.create_issue(project: "zwork", type: "Bug", summary: "This is content")`|
|`jira --action "createIssue" --type "Sub-task" --summary "This is content." --parent "249564"`|`jira.create_issue(type: "Sub-task", summary: "This is content.", parent: "249564")`|
|`jira --action "createOrUpdateIssue" --project "zjiracli" --type "bug" --summary "CreateOrUpdate - updated" --jql "project = zjiracli and summary ~ 'CreateOrUpdate: 1501339484158'"`|`jira.create_or_update_issue(project: "zjiracli", type: "bug", summary: "CreateOrUpdate - updated", jql: "project = zjiracli and summary ~ 'CreateOrUpdate: 1501339484158'")`|
|`jira --action "createOrUpdateIssue" --project "zjiracli" --type "task" --summary "createOrUpdate: 1501339484158" --jql "custom1 ~ UNDEFINED-TEXT-DATA"`|`jira.create_or_update_issue(project: "zjiracli", type: "task", summary: "createOrUpdate: 1501339484158", jql: "custom1 ~ UNDEFINED-TEXT-DATA")`|
|`jira --action "createProject" --project "ZAGILE" --name "zjiracliagile" --description "GINT test: jiracliagile" --lead "automation" --template "Template"`|`jira.create_project(project: "ZAGILE", name: "zjiracliagile", description: "GINT test: jiracliagile", lead: "automation", template: "Template")`|
|`jira --action "createProject" --project "ZATTACH" --name "zjiracliattachments" --description "GINT test: jiracliattachments" --lead "automation" --template "Template"`|`jira.create_project(project: "ZATTACH", name: "zjiracliattachments", description: "GINT test: jiracliattachments", lead: "automation", template: "Template")`|
|`jira --action "createProject" --project "ZCLICLONEB" --lead "automation" --type "business" --template "Task management" --issueTypeScheme "Default Issue Type Scheme" --issueTypeScreenScheme "Default Issue Type Screen Scheme" --permissionScheme "Default Permission Scheme"`|`jira.create_project(project: "ZCLICLONEB", lead: "automation", type: "business", template: "Task management", issue_type_scheme: "Default Issue Type Scheme", issue_type_screen_scheme: "Default Issue Type Screen Scheme", permission_scheme: "Default Permission Scheme")`|
|`jira --action "createProject" --project "ZCLICLONE" --lead "automation" --template "Template"`|`jira.create_project(project: "ZCLICLONE", lead: "automation", template: "Template")`|
|`jira --action "createProject" --project "ZCLICLONES" --lead "automation" --template "Basic" --issueTypeScheme "Default Issue Type Scheme" --issueTypeScreenScheme "Default Issue Type Screen Scheme" --permissionScheme "Default Permission Scheme"`|`jira.create_project(project: "ZCLICLONES", lead: "automation", template: "Basic", issue_type_scheme: "Default Issue Type Scheme", issue_type_screen_scheme: "Default Issue Type Screen Scheme", permission_scheme: "Default Permission Scheme")`|
|`jira --action "createProject" --project "ZCOMP2" --name "zjiraclicomponents2" --description "GINT test: jiraclicomponents" --lead "automation" --template "Template"`|`jira.create_project(project: "ZCOMP2", name: "zjiraclicomponents2", description: "GINT test: jiraclicomponents", lead: "automation", template: "Template")`|
|`jira --action "createProject" --project "ZCOMP" --name "zjiraclicomponents" --description "GINT test: jiraclicomponents" --lead "automation" --template "Template"`|`jira.create_project(project: "ZCOMP", name: "zjiraclicomponents", description: "GINT test: jiraclicomponents", lead: "automation", template: "Template")`|
|`jira --action "createProject" --project "ZCUSTOM" --name "zjiraclicustom" --description "GINT test: jiraclicustom" --lead "automation" --template "Template"`|`jira.create_project(project: "ZCUSTOM", name: "zjiraclicustom", description: "GINT test: jiraclicustom", lead: "automation", template: "Template")`|
|`jira --action "createProject" --project "ZEXPORT2" --name "zjiracliexport2" --description "GINT test: jiracliexport2" --lead "automation" --template "Template"`|`jira.create_project(project: "ZEXPORT2", name: "zjiracliexport2", description: "GINT test: jiracliexport2", lead: "automation", template: "Template")`|
|`jira --action "createProject" --project "ZEXPORT" --name "zjiracliexport" --description "GINT test: jiracliexport" --lead "automation" --template "Template"`|`jira.create_project(project: "ZEXPORT", name: "zjiracliexport", description: "GINT test: jiracliexport", lead: "automation", template: "Template")`|
|`jira --action "createProject" --project "ZFIELDS" --name "zjiraclifields" --description "GINT test: jiraclifields" --lead "automation" --template "Template"`|`jira.create_project(project: "ZFIELDS", name: "zjiraclifields", description: "GINT test: jiraclifields", lead: "automation", template: "Template")`|
|`jira --action "createProject" --project "ZFILTER" --name "zjiraclifilter" --description "GINT test: jiraclifilter" --lead "automation" --template "Template"`|`jira.create_project(project: "ZFILTER", name: "zjiraclifilter", description: "GINT test: jiraclifilter", lead: "automation", template: "Template")`|
|`jira --action "createProject" --project "ZHISTORY" --name "zjiraclihistory" --description "GINT test: jiraclihistory" --lead "automation" --template "Template"`|`jira.create_project(project: "ZHISTORY", name: "zjiraclihistory", description: "GINT test: jiraclihistory", lead: "automation", template: "Template")`|
|`jira --action "createProject" --project "zjiracliX" --template "Template" --workflowScheme "" --issueTypeScheme "Default Issue Type Scheme" --issueTypeScreenScheme "Default Issue Type Screen Scheme" --permissionScheme "Default Permission Scheme" --lead "automation" --name "zjiracliX for automated testing"`|`jira.create_project(project: "zjiracliX", template: "Template", workflow_scheme: "", issue_type_scheme: "Default Issue Type Scheme", issue_type_screen_scheme: "Default Issue Type Screen Scheme", permission_scheme: "Default Permission Scheme", lead: "automation", name: "zjiracliX for automated testing")`|
|`jira --action "createProject" --project "ZLINKS" --name "zjiraclilinks" --description "GINT test: jiraclilinks" --lead "automation" --template "Template"`|`jira.create_project(project: "ZLINKS", name: "zjiraclilinks", description: "GINT test: jiraclilinks", lead: "automation", template: "Template")`|
|`jira --action "createProject" --project "ZPROJECT" --name "zjiracliproject" --description "GINT test: jiracliproject" --lead "automation" --template "Template" --category "another"`|`jira.create_project(project: "ZPROJECT", name: "zjiracliproject", description: "GINT test: jiracliproject", lead: "automation", template: "Template", category: "another")`|
|`jira --action "createProject" --project "ZPROJECTX" --template "Template" --lead "developer" --workflowScheme "" --notificationScheme "" --category "another"`|`jira.create_project(project: "ZPROJECTX", template: "Template", lead: "developer", workflow_scheme: "", notification_scheme: "", category: "another")`|
|`jira --action "createProject" --project "ZPROJECTZ" --template "Kanban software development" --lead "admin"`|`jira.create_project(project: "ZPROJECTZ", template: "Kanban software development", lead: "admin")`|
|`jira --action "createProject" --project "ZROLES" --name "zjiracliroles" --description "GINT test: jiracliroles" --lead "automation" --template "Template"`|`jira.create_project(project: "ZROLES", name: "zjiracliroles", description: "GINT test: jiracliroles", lead: "automation", template: "Template")`|
|`jira --action "createProject" --project "ZROLESX" --name "zjiraclirolesX" --description "GINT test: jiracliroles" --lead "automation" --template "Template"`|`jira.create_project(project: "ZROLESX", name: "zjiraclirolesX", description: "GINT test: jiracliroles", lead: "automation", template: "Template")`|
|`jira --action "createProject" --project "ZRUNNERC" --name "zjiraclirunnerC" --description "GINT test: jiraclirunner" --lead "automation" --template "Template"`|`jira.create_project(project: "ZRUNNERC", name: "zjiraclirunnerC", description: "GINT test: jiraclirunner", lead: "automation", template: "Template")`|
|`jira --action "createProject" --project "ZRUNNER" --name "zjiraclirunner" --description "GINT test: jiraclirunner" --lead "automation" --template "Template"`|`jira.create_project(project: "ZRUNNER", name: "zjiraclirunner", description: "GINT test: jiraclirunner", lead: "automation", template: "Template")`|
|`jira --action "createProject" --project "ZSUB" --name "zjiraclisub" --description "GINT test: jiraclisub" --lead "automation" --template "Template" --issueSecurityScheme "test restrictions" --category "standard"`|`jira.create_project(project: "ZSUB", name: "zjiraclisub", description: "GINT test: jiraclisub", lead: "automation", template: "Template", issue_security_scheme: "test restrictions", category: "standard")`|
|`jira --action "createProject" --project "ZSUPPORT" --name "zjiraclisupport" --description "GINT test: jiraclisupport" --lead "automation" --template "Template" --issueSecurityScheme "test restrictions" --category "standard"`|`jira.create_project(project: "ZSUPPORT", name: "zjiraclisupport", description: "GINT test: jiraclisupport", lead: "automation", template: "Template", issue_security_scheme: "test restrictions", category: "standard")`|
|`jira --action "createProject" --project "ZUSER" --name "zjiracliuser" --description "GINT test: jiracliuser" --lead "automation" --template "Template"`|`jira.create_project(project: "ZUSER", name: "zjiracliuser", description: "GINT test: jiracliuser", lead: "automation", template: "Template")`|
|`jira --action "createProject" --project "ZVOTEWATCH" --name "zjiraclivotewatch" --description "GINT test: jiraclivotewatch" --lead "automation" --template "Template"`|`jira.create_project(project: "ZVOTEWATCH", name: "zjiraclivotewatch", description: "GINT test: jiraclivotewatch", lead: "automation", template: "Template")`|
|`jira --action "createProject" --project "ZWORK" --name "zjiracliwork" --description "GINT test: jiracliwork" --lead "automation" --template "Template"`|`jira.create_project(project: "ZWORK", name: "zjiracliwork", description: "GINT test: jiracliwork", lead: "automation", template: "Template")`|
|`jira --action "deleteBoard" --board "NOT_FOUND" --continue`|`jira.delete_board(board: "NOT_FOUND", continue: true)`|
|`jira --action "deleteBoard" --board "ZAGILE" --deleteFilter`|`jira.delete_board(board: "ZAGILE", delete_filter: true)`|
|`jira --action "deleteBoard" --id "1228" --deleteFilter`|`jira.delete_board(id: "1228", delete_filter: true)`|
|`jira --action "deleteBoard" --id "1234567890" --continue`|`jira.delete_board(id: "1234567890", continue: true)`|
|`jira --action "deleteComponent" --project "zjiracli" --component "71357"`|`jira.delete_component(project: "zjiracli", component: "71357")`|
|`jira --action "deleteComponent" --project "zjiracli" --component "swap1" --toComponent "swap2"`|`jira.delete_component(project: "zjiracli", component: "swap1", to_component: "swap2")`|
|`jira --action "deleteComponent" --project "zjiracli" --name "auto1"`|`jira.delete_component(project: "zjiracli", name: "auto1")`|
|`jira --action "deleteComponent" --project "zjiracli" --name "auto2"`|`jira.delete_component(project: "zjiracli", name: "auto2")`|
|`jira --action "deleteComponent" --project "zjiracliX" --component "C2"`|`jira.delete_component(project: "zjiracliX", component: "C2")`|
|`jira --action "deleteComponent" --project "zjiracliX" --component "C3"`|`jira.delete_component(project: "zjiracliX", component: "C3")`|
|`jira --action "deleteComponent" --project "zjiracliX" --name "C1"`|`jira.delete_component(project: "zjiracliX", name: "C1")`|
|`jira --action "deleteComponent" --project "zjiracliX" --name "C1" --continue`|`jira.delete_component(project: "zjiracliX", name: "C1", continue: true)`|
|`jira --action "deleteFieldConfiguration" --id "1234556780" --continue`|`jira.delete_field_configuration(id: "1234556780", continue: true)`|
|`jira --action "deleteFieldConfigurationScheme" --id "1234556780" --continue`|`jira.delete_field_configuration_scheme(id: "1234556780", continue: true)`|
|`jira --action "deleteFilter" --filter "NOT_FOUND" --continue`|`jira.delete_filter(filter: "NOT_FOUND", continue: true)`|
|`jira --action "deleteFilter" --id "1234567890" --continue`|`jira.delete_filter(id: "1234567890", continue: true)`|
|`jira --action "deleteFilter" --id "24903"`|`jira.delete_filter(id: "24903")`|
|`jira --action "deleteIssue" --issue "ZJIRACLI-1"`|`jira.delete_issue(issue: "ZJIRACLI-1")`|
|`jira --action "deleteIssue" --issue "ZJIRACLI-1" --continue`|`jira.delete_issue(issue: "ZJIRACLI-1", continue: true)`|
|`jira --action "deleteIssueSecurityScheme" --id "1234556780" --continue`|`jira.delete_issue_security_scheme(id: "1234556780", continue: true)`|
|`jira --action "deleteIssueTypeScheme" --id "1234556780" --continue`|`jira.delete_issue_type_scheme(id: "1234556780", continue: true)`|
|`jira --action "deleteIssueTypeScreenScheme" --id "1234556780" --continue`|`jira.delete_issue_type_screen_scheme(id: "1234556780", continue: true)`|
|`jira --action "deleteLink" --issue "249453" --toIssue "249454" --link "10011"`|`jira.delete_link(issue: "249453", to_issue: "249454", link: "10011")`|
|`jira --action "deleteLink" --issue "ZLINKS-1" --toIssue "ZLINKS-3" --link "duplicates"`|`jira.delete_link(issue: "ZLINKS-1", to_issue: "ZLINKS-3", link: "duplicates")`|
|`jira --action "deleteNotificationScheme" --id "1234556780" --continue`|`jira.delete_notification_scheme(id: "1234556780", continue: true)`|
|`jira --action "deletePermissionScheme" --id "1234556780" --continue`|`jira.delete_permission_scheme(id: "1234556780", continue: true)`|
|`jira --action "deleteProject" --project "NOT_FOUND" --continue`|`jira.delete_project(project: "NOT_FOUND", continue: true)`|
|`jira --action "deleteProject" --project "ZAGILEC" --continue`|`jira.delete_project(project: "ZAGILEC", continue: true)`|
|`jira --action "deleteProject" --project "ZAGILE" --continue`|`jira.delete_project(project: "ZAGILE", continue: true)`|
|`jira --action "deleteProject" --project "ZATTACH2" --continue`|`jira.delete_project(project: "ZATTACH2", continue: true)`|
|`jira --action "deleteProject" --project "ZATTACH" --continue`|`jira.delete_project(project: "ZATTACH", continue: true)`|
|`jira --action "deleteProject" --project "ZCLICLONEB" --continue`|`jira.delete_project(project: "ZCLICLONEB", continue: true)`|
|`jira --action "deleteProject" --project "ZCLICLONE" --continue`|`jira.delete_project(project: "ZCLICLONE", continue: true)`|
|`jira --action "deleteProject" --project "ZCLICLONES" --continue`|`jira.delete_project(project: "ZCLICLONES", continue: true)`|
|`jira --action "deleteProject" --project "ZCLICLONET" --continue`|`jira.delete_project(project: "ZCLICLONET", continue: true)`|
|`jira --action "deleteProject" --project "ZCLICLONEX" --continue`|`jira.delete_project(project: "ZCLICLONEX", continue: true)`|
|`jira --action "deleteProject" --project "ZCLICLONEY" --continue`|`jira.delete_project(project: "ZCLICLONEY", continue: true)`|
|`jira --action "deleteProject" --project "ZCLICLONEZ" --continue`|`jira.delete_project(project: "ZCLICLONEZ", continue: true)`|
|`jira --action "deleteProject" --project "ZCOMP2" --continue`|`jira.delete_project(project: "ZCOMP2", continue: true)`|
|`jira --action "deleteProject" --project "ZCOMP" --continue`|`jira.delete_project(project: "ZCOMP", continue: true)`|
|`jira --action "deleteProject" --project "ZCUSTOM" --continue`|`jira.delete_project(project: "ZCUSTOM", continue: true)`|
|`jira --action "deleteProject" --project "ZEXPORT2" --continue`|`jira.delete_project(project: "ZEXPORT2", continue: true)`|
|`jira --action "deleteProject" --project "ZEXPORT2E" --continue`|`jira.delete_project(project: "ZEXPORT2E", continue: true)`|
|`jira --action "deleteProject" --project "ZEXPORT" --continue`|`jira.delete_project(project: "ZEXPORT", continue: true)`|
|`jira --action "deleteProject" --project "ZFIELDS" --continue`|`jira.delete_project(project: "ZFIELDS", continue: true)`|
|`jira --action "deleteProject" --project "ZFILTER" --continue`|`jira.delete_project(project: "ZFILTER", continue: true)`|
|`jira --action "deleteProject" --project "ZHISTORY" --continue`|`jira.delete_project(project: "ZHISTORY", continue: true)`|
|`jira --action "deleteProject" --project "ZIMPORT" --continue`|`jira.delete_project(project: "ZIMPORT", continue: true)`|
|`jira --action "deleteProject" --project "ZJIRACLIA" --continue`|`jira.delete_project(project: "ZJIRACLIA", continue: true)`|
|`jira --action "deleteProject" --project "ZJIRACLIB" --continue`|`jira.delete_project(project: "ZJIRACLIB", continue: true)`|
|`jira --action "deleteProject" --project "ZJIRACLIC" --continue`|`jira.delete_project(project: "ZJIRACLIC", continue: true)`|
|`jira --action "deleteProject" --project "ZJIRACLI" --continue`|`jira.delete_project(project: "ZJIRACLI", continue: true)`|
|`jira --action "deleteProject" --project "ZJIRACLID" --continue`|`jira.delete_project(project: "ZJIRACLID", continue: true)`|
|`jira --action "deleteProject" --project "ZJIRACLIE" --continue`|`jira.delete_project(project: "ZJIRACLIE", continue: true)`|
|`jira --action "deleteProject" --project "ZJIRACLIX" --continue`|`jira.delete_project(project: "ZJIRACLIX", continue: true)`|
|`jira --action "deleteProject" --project "ZLINKS" --continue`|`jira.delete_project(project: "ZLINKS", continue: true)`|
|`jira --action "deleteProject" --project "ZPROJECT" --continue`|`jira.delete_project(project: "ZPROJECT", continue: true)`|
|`jira --action "deleteProject" --project "ZPROJECTE" --continue`|`jira.delete_project(project: "ZPROJECTE", continue: true)`|
|`jira --action "deleteProject" --project "ZPROJECTX" --continue`|`jira.delete_project(project: "ZPROJECTX", continue: true)`|
|`jira --action "deleteProject" --project "ZPROJECTZ" --continue`|`jira.delete_project(project: "ZPROJECTZ", continue: true)`|
|`jira --action "deleteProject" --project "ZROLES" --continue`|`jira.delete_project(project: "ZROLES", continue: true)`|
|`jira --action "deleteProject" --project "ZROLESX" --continue`|`jira.delete_project(project: "ZROLESX", continue: true)`|
|`jira --action "deleteProject" --project "ZRUNNERC" --continue`|`jira.delete_project(project: "ZRUNNERC", continue: true)`|
|`jira --action "deleteProject" --project "ZRUNNER" --continue`|`jira.delete_project(project: "ZRUNNER", continue: true)`|
|`jira --action "deleteProject" --project "ZSUB" --continue`|`jira.delete_project(project: "ZSUB", continue: true)`|
|`jira --action "deleteProject" --project "ZSUPPORT" --continue`|`jira.delete_project(project: "ZSUPPORT", continue: true)`|
|`jira --action "deleteProject" --project "ZUSER" --continue`|`jira.delete_project(project: "ZUSER", continue: true)`|
|`jira --action "deleteProject" --project "ZVOTEWATCH" --continue`|`jira.delete_project(project: "ZVOTEWATCH", continue: true)`|
|`jira --action "deleteProject" --project "ZWORK" --continue`|`jira.delete_project(project: "ZWORK", continue: true)`|
|`jira --action "deleteScreen" --id "1234556780" --continue`|`jira.delete_screen(id: "1234556780", continue: true)`|
|`jira --action "deleteScreenScheme" --id "1234556780" --continue`|`jira.delete_screen_scheme(id: "1234556780", continue: true)`|
|`jira --action "deleteVersion" --project "zjiracli" --version "auto2" --continue`|`jira.delete_version(project: "zjiracli", version: "auto2", continue: true)`|
|`jira --action "deleteVersion" --project "zjiracli" --version "BAD" --continue`|`jira.delete_version(project: "zjiracli", version: "BAD", continue: true)`|
|`jira --action "deleteVersion" --project "zjiracli" --version "swap1" --affectsVersions "swap2" --fixVersions "swap2"`|`jira.delete_version(project: "zjiracli", version: "swap1", affects_versions: "swap2", fix_versions: "swap2")`|
|`jira --action "deleteVersion" --project "zjiracli" --version "swap2" --fixVersions "swap3" --autoVersion --verbose`|`jira.delete_version(project: "zjiracli", version: "swap2", fix_versions: "swap3", auto_version: true, verbose: true)`|
|`jira --action "deleteVersion" --project "zjiracli" --version "swap3"`|`jira.delete_version(project: "zjiracli", version: "swap3")`|
|`jira --action "deleteVersion" --project "ZRUNNER" --version "auto1csv"`|`jira.delete_version(project: "ZRUNNER", version: "auto1csv")`|
|`jira --action "deleteWorkflow" --name "zjiracliworkflow" --continue`|`jira.delete_workflow(name: "zjiracliworkflow", continue: true)`|
|`jira --action "deleteWorkflow" --name "zjiracliworkflow_new" --continue`|`jira.delete_workflow(name: "zjiracliworkflow_new", continue: true)`|
|`jira --action "deleteWorkflowScheme" --name "zjiracliworkflow" --continue`|`jira.delete_workflow_scheme(name: "zjiracliworkflow", continue: true)`|
|`jira --action "exportData" --project "ZEXPORT2" --exportType "Participants"`|`jira.export_data(project: "ZEXPORT2", export_type: "Participants")`|
|`jira --action "exportData" --project "ZEXPORT2" --file "target/output/jiracliexport2/exportDataProject.txt"`|`jira.export_data(project: "ZEXPORT2", file: "target/output/jiracliexport2/exportDataProject.txt")`|
|`jira --action "exportSite"`|`jira.export_site`|
|`jira --action "exportWorkflow" --file "target/output/jiracliworkflow/exportWorkflow.txt" --workflow "jira"`|`jira.export_workflow(file: "target/output/jiracliworkflow/exportWorkflow.txt", workflow: "jira")`|
|`jira --action "getApplicationLinkList" --regex "(?i)((confluence)|(jira)).*"`|`jira.get_application_link_list(regex: "(?i)((confluence)|(jira)).*")`|
|`jira --action "getAttachment" --issue "ZATTACH-1" --file "target/output/jiracliattachments/binary.bin" --verbose`|`jira.get_attachment(issue: "ZATTACH-1", file: "target/output/jiracliattachments/binary.bin", verbose: true)`|
|`jira --action "getAttachment" --issue "ZATTACH-1" --file "target/output/jiracliattachments/dataFromStandardInput.txt" --findReplace "xxx:yyy" --verbose`|`jira.get_attachment(issue: "ZATTACH-1", file: "target/output/jiracliattachments/dataFromStandardInput.txt", find_replace: "xxx:yyy", verbose: true)`|
|`jira --action "getAttachment" --issue "ZATTACH-1" --file "target/output/jiracliattachments/data.txt" --findReplace "xxx:yyy"`|`jira.get_attachment(issue: "ZATTACH-1", file: "target/output/jiracliattachments/data.txt", find_replace: "xxx:yyy")`|
|`jira --action "getAttachment" --issue "ZATTACH-1" --file "target/output/jiracliattachments/getAttachment2.txt" --name "data.txt" --findReplace "xxx:yyy"`|`jira.get_attachment(issue: "ZATTACH-1", file: "target/output/jiracliattachments/getAttachment2.txt", name: "data.txt", find_replace: "xxx:yyy")`|
|`jira --action "getAttachment" --issue "ZATTACH-1" --file "target/output/jiracliattachments/large.zip" --verbose`|`jira.get_attachment(issue: "ZATTACH-1", file: "target/output/jiracliattachments/large.zip", verbose: true)`|
|`jira --action "getAttachment" --issue "ZATTACH-1" --file "target/output/jiracliattachments/Special name #&?"`|`jira.get_attachment(issue: "ZATTACH-1", file: "target/output/jiracliattachments/Special name #&?")`|
|`jira --action "getAttachmentList" --issue "ZATTACH-1" --dateFormat "yyyy-MM-dd HH:mm:ss:S"`|`jira.get_attachment_list(issue: "ZATTACH-1", date_format: "yyyy-MM-dd HH:mm:ss:S")`|
|`jira --action "getAttachmentList" --issue "ZATTACH-1" --dateFormat "yyyy-MM-dd 'special format' HH:mm:ss:S z"`|`jira.get_attachment_list(issue: "ZATTACH-1", date_format: "yyyy-MM-dd 'special format' HH:mm:ss:S z")`|
|`jira --action "getAvailableSteps" --issue "ZJIRACLI-3"`|`jira.get_available_steps(issue: "ZJIRACLI-3")`|
|`jira --action "getBoardList"`|`jira.get_board_list`|
|`jira --action "getBoardList" --regex "ZAGILE.*"`|`jira.get_board_list(regex: "ZAGILE.*")`|
|`jira --action "getClientInfo"`|`jira.get_client_info`|
|`jira --action "getCommentList" --issue "ZCLICLONE-6"`|`jira.get_comment_list(issue: "ZCLICLONE-6")`|
|`jira --action "getCommentList" --issue "ZJIRACLI-1" --dateFormat "yyyy-MM-dd"`|`jira.get_comment_list(issue: "ZJIRACLI-1", date_format: "yyyy-MM-dd")`|
|`jira --action "getCommentList" --issue "ZSUB-3" --limit "2"`|`jira.get_comment_list(issue: "ZSUB-3", limit: "2")`|
|`jira --action "getComments" --issue "ZJIRACLI-12"`|`jira.get_comments(issue: "ZJIRACLI-12")`|
|`jira --action "getComments" --issue "ZLINKS-1"`|`jira.get_comments(issue: "ZLINKS-1")`|
|`jira --action "getComponentList" --project "ZCOMP2" --outputFormat "999"`|`jira.get_component_list(project: "ZCOMP2", output_format: "999")`|
|`jira --action "getComponentList" --project "ZCOMP" --outputFormat "999"`|`jira.get_component_list(project: "ZCOMP", output_format: "999")`|
|`jira --action "getComponentList" --project "zjiracli" --file "target/output/jiracli/getComponentList.txt"`|`jira.get_component_list(project: "zjiracli", file: "target/output/jiracli/getComponentList.txt")`|
|`jira --action "getComponentList" --project "zjiracli" --outputFormat "999"`|`jira.get_component_list(project: "zjiracli", output_format: "999")`|
|`jira --action "getComponent" --project "zjiracli" --component "C2"`|`jira.get_component(project: "zjiracli", component: "C2")`|
|`jira --action "getComponent" --project "zjiracli" --component "C3"`|`jira.get_component(project: "zjiracli", component: "C3")`|
|`jira --action "getComponent" --project "zjiracli" --component "C3First"`|`jira.get_component(project: "zjiracli", component: "C3First")`|
|`jira --action "getCustomFieldList"`|`jira.get_custom_field_list`|
|`jira --action "getCustomFieldList" --regex "zzz_.*"`|`jira.get_custom_field_list(regex: "zzz_.*")`|
|`jira --action "getFieldConfigurationList"`|`jira.get_field_configuration_list`|
|`jira --action "getFieldConfigurationList" --options "deleteEnabled"`|`jira.get_field_configuration_list(options: "deleteEnabled")`|
|`jira --action "getFieldConfigurationSchemeList"`|`jira.get_field_configuration_scheme_list`|
|`jira --action "getFieldConfigurationSchemeList" --options "deleteEnabled"`|`jira.get_field_configuration_scheme_list(options: "deleteEnabled")`|
|`jira --action "getFieldList"`|`jira.get_field_list`|
|`jira --action "getFieldList" --regex "customfield_.*"`|`jira.get_field_list(regex: "customfield_.*")`|
|`jira --action "getFieldValue" --issue "ZCUSTOM-1" --field "custom-cascade-select"`|`jira.get_field_value(issue: "ZCUSTOM-1", field: "custom-cascade-select")`|
|`jira --action "getFieldValue" --issue "ZCUSTOM-4" --field "custom-multi-select"`|`jira.get_field_value(issue: "ZCUSTOM-4", field: "custom-multi-select")`|
|`jira --action "getFieldValue" --issue "ZCUSTOM-5" --field "custom-multi-checkbox"`|`jira.get_field_value(issue: "ZCUSTOM-5", field: "custom-multi-checkbox")`|
|`jira --action "getFieldValue" --issue "ZFIELDS-1" --field "custom1"`|`jira.get_field_value(issue: "ZFIELDS-1", field: "custom1")`|
|`jira --action "getFieldValue" --issue "ZFIELDS-1" --field "custom-datetime" --dateFormat "dd/MM/yyyy HH:mm:ss"`|`jira.get_field_value(issue: "ZFIELDS-1", field: "custom-datetime", date_format: "dd/MM/yyyy HH:mm:ss")`|
|`jira --action "getFieldValue" --issue "ZFIELDS-1" --field "description"`|`jira.get_field_value(issue: "ZFIELDS-1", field: "description")`|
|`jira --action "getFieldValue" --issue "ZFIELDS-1" --field "environment"`|`jira.get_field_value(issue: "ZFIELDS-1", field: "environment")`|
|`jira --action "getFieldValue" --issue "ZFIELDS-2" --field "custom1"`|`jira.get_field_value(issue: "ZFIELDS-2", field: "custom1")`|
|`jira --action "getFieldValue" --issue "ZFIELDS-2" --field "custom-multi-select" --suppressId`|`jira.get_field_value(issue: "ZFIELDS-2", field: "custom-multi-select", suppress_id: true)`|
|`jira --action "getFieldValue" --issue "ZFIELDS-2" --field "custom-multi-select" --withId`|`jira.get_field_value(issue: "ZFIELDS-2", field: "custom-multi-select", with_id: true)`|
|`jira --action "getFieldValue" --issue "ZFIELDS-3" --field "description" --withId`|`jira.get_field_value(issue: "ZFIELDS-3", field: "description", with_id: true)`|
|`jira --action "getFieldValue" --issue "ZFIELDS-3" --field "priority" --withId`|`jira.get_field_value(issue: "ZFIELDS-3", field: "priority", with_id: true)`|
|`jira --action "getFieldValue" --issue "ZFIELDS-3" --field "reporter" --withId`|`jira.get_field_value(issue: "ZFIELDS-3", field: "reporter", with_id: true)`|
|`jira --action "getFieldValue" --issue "ZFIELDS-3" --field "summary" --withId`|`jira.get_field_value(issue: "ZFIELDS-3", field: "summary", with_id: true)`|
|`jira --action "getFieldValue" --issue "ZFIELDS-3" --field "type" --withId`|`jira.get_field_value(issue: "ZFIELDS-3", field: "type", with_id: true)`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-10" --field "custom-versions" --asVersion`|`jira.get_field_value(issue: "ZJIRACLI-10", field: "custom-versions", as_version: true)`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-11" --field "custom1"`|`jira.get_field_value(issue: "ZJIRACLI-11", field: "custom1")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-11" --field "custom2"`|`jira.get_field_value(issue: "ZJIRACLI-11", field: "custom2")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-11" --field "custom-versions" --asVersion`|`jira.get_field_value(issue: "ZJIRACLI-11", field: "custom-versions", as_version: true)`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-3" --field "affectsVersions"`|`jira.get_field_value(issue: "ZJIRACLI-3", field: "affectsVersions")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-3" --field "assignee" --dateFormat "d/MMM/yy"`|`jira.get_field_value(issue: "ZJIRACLI-3", field: "assignee", date_format: "d/MMM/yy")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-3" --field "components"`|`jira.get_field_value(issue: "ZJIRACLI-3", field: "components")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-3" --field "custom-labels"`|`jira.get_field_value(issue: "ZJIRACLI-3", field: "custom-labels")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-3" --field "duedate" --dateFormat "d/MMM/yy"`|`jira.get_field_value(issue: "ZJIRACLI-3", field: "duedate", date_format: "d/MMM/yy")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-3" --field "environment"`|`jira.get_field_value(issue: "ZJIRACLI-3", field: "environment")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-3" --field "fixversions"`|`jira.get_field_value(issue: "ZJIRACLI-3", field: "fixversions")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-3" --field "fixVersions"`|`jira.get_field_value(issue: "ZJIRACLI-3", field: "fixVersions")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-3" --field "fixversions" --dateFormat "d/MMM/yy"`|`jira.get_field_value(issue: "ZJIRACLI-3", field: "fixversions", date_format: "d/MMM/yy")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-3" --field "parent"`|`jira.get_field_value(issue: "ZJIRACLI-3", field: "parent")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-3" --field "reporter" --dateFormat "d/MMM/yy"`|`jira.get_field_value(issue: "ZJIRACLI-3", field: "reporter", date_format: "d/MMM/yy")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-3" --field "resolution"`|`jira.get_field_value(issue: "ZJIRACLI-3", field: "resolution")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-3" --field "resolutionDate" --dateFormat "d/MMM/yy"`|`jira.get_field_value(issue: "ZJIRACLI-3", field: "resolutionDate", date_format: "d/MMM/yy")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-3" --field "resolution" --dateFormat "d/MMM/yy"`|`jira.get_field_value(issue: "ZJIRACLI-3", field: "resolution", date_format: "d/MMM/yy")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-3" --field "summary"`|`jira.get_field_value(issue: "ZJIRACLI-3", field: "summary")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-5" --field "10010"`|`jira.get_field_value(issue: "ZJIRACLI-5", field: "10010")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-5" --field "assignee"`|`jira.get_field_value(issue: "ZJIRACLI-5", field: "assignee")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-5" --field "currentESTIMATE"`|`jira.get_field_value(issue: "ZJIRACLI-5", field: "currentESTIMATE")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-5" --field "custom1"`|`jira.get_field_value(issue: "ZJIRACLI-5", field: "custom1")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-5" --field "customfield_10010"`|`jira.get_field_value(issue: "ZJIRACLI-5", field: "customfield_10010")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-5" --field "custom three"`|`jira.get_field_value(issue: "ZJIRACLI-5", field: "custom three")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-5" --field "custom-versions" --asVersion`|`jira.get_field_value(issue: "ZJIRACLI-5", field: "custom-versions", as_version: true)`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-5" --field "custom-versions" --suppressId`|`jira.get_field_value(issue: "ZJIRACLI-5", field: "custom-versions", suppress_id: true)`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-5" --field "duedate"`|`jira.get_field_value(issue: "ZJIRACLI-5", field: "duedate")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-5" --field "duedate" --dateFormat "yyyy-MM-dd"`|`jira.get_field_value(issue: "ZJIRACLI-5", field: "duedate", date_format: "yyyy-MM-dd")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-5" --field "duedate" --dateFormat "yyyy.MM.dd"`|`jira.get_field_value(issue: "ZJIRACLI-5", field: "duedate", date_format: "yyyy.MM.dd")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-5" --field "originalEstimate"`|`jira.get_field_value(issue: "ZJIRACLI-5", field: "originalEstimate")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-5" --field "parent"`|`jira.get_field_value(issue: "ZJIRACLI-5", field: "parent")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-5" --field "TIMEESTIMATE"`|`jira.get_field_value(issue: "ZJIRACLI-5", field: "TIMEESTIMATE")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-5" --field "timespent"`|`jira.get_field_value(issue: "ZJIRACLI-5", field: "timespent")`|
|`jira --action "getFieldValue" --issue "ZJIRACLI-8" --field "labels"`|`jira.get_field_value(issue: "ZJIRACLI-8", field: "labels")`|
|`jira --action "getFieldValue" --issue "ZJIRACLIX-1" --field "assignee"`|`jira.get_field_value(issue: "ZJIRACLIX-1", field: "assignee")`|
|`jira --action "getFieldValue" --issue "ZJIRACLIX-2" --field "assignee"`|`jira.get_field_value(issue: "ZJIRACLIX-2", field: "assignee")`|
|`jira --action "getFieldValue" --issue "ZSUB-3" --field "testcase1"`|`jira.get_field_value(issue: "ZSUB-3", field: "testcase1")`|
|`jira --action "getFieldValue" --issue "ZSUB-4" --field "environment"`|`jira.get_field_value(issue: "ZSUB-4", field: "environment")`|
|`jira --action "getFilter" --id "24903"`|`jira.get_filter(id: "24903")`|
|`jira --action "getFilterList"`|`jira.get_filter_list`|
|`jira --action "getGroupList"`|`jira.get_group_list`|
|`jira --action "getGroupList" --regex "jira.*"`|`jira.get_group_list(regex: "jira.*")`|
|`jira --action "getIssueHistoryList" --issue "ZHISTORY-1"`|`jira.get_issue_history_list(issue: "ZHISTORY-1")`|
|`jira --action "getIssueHistoryList" --issue "ZHISTORY-1" --dateFormat "yyyy-MM-dd HH:mm:ss.SSS"`|`jira.get_issue_history_list(issue: "ZHISTORY-1", date_format: "yyyy-MM-dd HH:mm:ss.SSS")`|
|`jira --action "getIssue" --issue "ZAGILE-2" --dateFormat "yyyy-MM-dd HH:mm:ss.SSS" --outputFormat "2" --suppressId`|`jira.get_issue(issue: "ZAGILE-2", date_format: "yyyy-MM-dd HH:mm:ss.SSS", output_format: "2", suppress_id: true)`|
|`jira --action "getIssue" --issue "ZCLICLONE-6" --outputFormat "999"`|`jira.get_issue(issue: "ZCLICLONE-6", output_format: "999")`|
|`jira --action "getIssue" --issue "ZCUSTOM-2"`|`jira.get_issue(issue: "ZCUSTOM-2")`|
|`jira --action "getIssue" --issue "ZCUSTOM-3"`|`jira.get_issue(issue: "ZCUSTOM-3")`|
|`jira --action "getIssue" --issue "ZCUSTOM-6" --dateFormat "yyyy-MM-dd"`|`jira.get_issue(issue: "ZCUSTOM-6", date_format: "yyyy-MM-dd")`|
|`jira --action "getIssue" --issue "ZCUSTOM-7"`|`jira.get_issue(issue: "ZCUSTOM-7")`|
|`jira --action "getIssue" --issue "ZCUSTOM-7" --dateFormat "yyyy-MM-dd"`|`jira.get_issue(issue: "ZCUSTOM-7", date_format: "yyyy-MM-dd")`|
|`jira --action "getIssue" --issue "ZFIELDS-3"`|`jira.get_issue(issue: "ZFIELDS-3")`|
|`jira --action "getIssue" --issue "ZFIELDS-4" --suppressId`|`jira.get_issue(issue: "ZFIELDS-4", suppress_id: true)`|
|`jira --action "getIssue" --issue "ZJIRACLI-12"`|`jira.get_issue(issue: "ZJIRACLI-12")`|
|`jira --action "getIssue" --issue "ZJIRACLI-13"`|`jira.get_issue(issue: "ZJIRACLI-13")`|
|`jira --action "getIssue" --issue "ZJIRACLI-3" --dateFormat "M/dd/yyyy HH:mm:ss" --outputFormat "2" --suppressId`|`jira.get_issue(issue: "ZJIRACLI-3", date_format: "M/dd/yyyy HH:mm:ss", output_format: "2", suppress_id: true)`|
|`jira --action "getIssue" --issue "ZJIRACLI-3" --dateFormat "yyyy.MM.dd 'special format' HH:mm:ss z""" --outputFormat "2"`|`jira.get_issue(issue: "ZJIRACLI-3", date_format: "yyyy.MM.dd 'special format' HH:mm:ss z\"\"", output_format: "2")`|
|`jira --action "getIssue" --issue "ZJIRACLI-3" --outputFormat "2"`|`jira.get_issue(issue: "ZJIRACLI-3", output_format: "2")`|
|`jira --action "getIssue" --issue "ZJIRACLI-5" --field "assignee"`|`jira.get_issue(issue: "ZJIRACLI-5", field: "assignee")`|
|`jira --action "getIssue" --issue "ZJIRACLI-5" --outputFormat "2"`|`jira.get_issue(issue: "ZJIRACLI-5", output_format: "2")`|
|`jira --action "getIssue" --issue "ZJIRACLI-8" --outputFormat "2"`|`jira.get_issue(issue: "ZJIRACLI-8", output_format: "2")`|
|`jira --action "getIssue" --issue "ZJIRACLIB-2"`|`jira.get_issue(issue: "ZJIRACLIB-2")`|
|`jira --action "getIssue" --issue "ZJIRACLIB-2" --dateFormat "yyyy.MM.dd 'special format' HH:mm:ss z"""`|`jira.get_issue(issue: "ZJIRACLIB-2", date_format: "yyyy.MM.dd 'special format' HH:mm:ss z\"\"")`|
|`jira --action "getIssue" --issue "ZLINKS-1" --outputFormat "2"`|`jira.get_issue(issue: "ZLINKS-1", output_format: "2")`|
|`jira --action "getIssue" --issue "ZSUB-1" --suppressId`|`jira.get_issue(issue: "ZSUB-1", suppress_id: true)`|
|`jira --action "getIssue" --issue "ZSUB-2" --suppressId`|`jira.get_issue(issue: "ZSUB-2", suppress_id: true)`|
|`jira --action "getIssue" --issue "ZUSER-1"`|`jira.get_issue(issue: "ZUSER-1")`|
|`jira --action "getIssue" --issue "ZWORK-1" --outputFormat "2"`|`jira.get_issue(issue: "ZWORK-1", output_format: "2")`|
|`jira --action "getIssue" --issue "ZWORK-2" --outputFormat "2"`|`jira.get_issue(issue: "ZWORK-2", output_format: "2")`|
|`jira --action "getIssueList" --file "target/output/jiracliclone/getIssueListChangeType.txt" --jql "project = ZCLICLONEX and type = 'improvement'"`|`jira.get_issue_list(file: "target/output/jiracliclone/getIssueListChangeType.txt", jql: "project = ZCLICLONEX and type = 'improvement'")`|
|`jira --action "getIssueList" --file "target/output/jiracli/getIssueListAllFieldsExceptCustom.txt" --jql "project = 'zjiracli'" --outputFormat "998"`|`jira.get_issue_list(file: "target/output/jiracli/getIssueListAllFieldsExceptCustom.txt", jql: "project = 'zjiracli'", output_format: "998")`|
|`jira --action "getIssueList" --file "target/output/jiracli/getIssueListAllFields.txt" --jql "project = 'zjiracli'" --outputFormat "999"`|`jira.get_issue_list(file: "target/output/jiracli/getIssueListAllFields.txt", jql: "project = 'zjiracli'", output_format: "999")`|
|`jira --action "getIssueList" --file "target/output/jiracli/getIssueListChangeType.txt" --jql "project = zjiracliA and type = 'improvement'"`|`jira.get_issue_list(file: "target/output/jiracli/getIssueListChangeType.txt", jql: "project = zjiracliA and type = 'improvement'")`|
|`jira --action "getIssueList" --file "target/output/jiracli/getIssueListOutputFormat200.txt" --jql "project = 'zjiracli'" --outputFormat "200"`|`jira.get_issue_list(file: "target/output/jiracli/getIssueListOutputFormat200.txt", jql: "project = 'zjiracli'", output_format: "200")`|
|`jira --action "getIssueList" --file "target/output/jiracli/getIssueListSearch.txt" --jql "project = zjiracli or project = zjiracliX"`|`jira.get_issue_list(file: "target/output/jiracli/getIssueListSearch.txt", jql: "project = zjiracli or project = zjiracliX")`|
|`jira --action "getIssueList" --file "target/output/jiracli/getIssueList.txt" --filter "all"`|`jira.get_issue_list(file: "target/output/jiracli/getIssueList.txt", filter: "all")`|
|`jira --action "getIssueList" --filter "all" --outputFormat "2" --limit "75"`|`jira.get_issue_list(filter: "all", output_format: "2", limit: "75")`|
|`jira --action "getIssueList" --jql "issuetype in subTaskIssueTypes() and parent = ZJIRACLI-3"`|`jira.get_issue_list(jql: "issuetype in subTaskIssueTypes() and parent = ZJIRACLI-3")`|
|`jira --action "getIssueList" --jql "issue = ZJIRACLIB-2" --outputFormat "2"`|`jira.get_issue_list(jql: "issue = ZJIRACLIB-2", output_format: "2")`|
|`jira --action "getIssueList" --jql "issue = ZJIRACLIB-2" --outputFormat "3"`|`jira.get_issue_list(jql: "issue = ZJIRACLIB-2", output_format: "3")`|
|`jira --action "getIssueList" --jql "issue = ZVOTEWATCH-1 and watcher = 'user' and watcher = 'developer'"`|`jira.get_issue_list(jql: "issue = ZVOTEWATCH-1 and watcher = 'user' and watcher = 'developer'")`|
|`jira --action "getIssueList" --jql "issue = ZVOTEWATCH-1 and (watcher = 'user' or watcher = 'developer')"`|`jira.get_issue_list(jql: "issue = ZVOTEWATCH-1 and (watcher = 'user' or watcher = 'developer')")`|
|`jira --action "getIssueList" --jql "issue = ZWORK-1" --outputFormat "5"`|`jira.get_issue_list(jql: "issue = ZWORK-1", output_format: "5")`|
|`jira --action "getIssueList" --jql "key = ZCUSTOM-4" --outputFormat "2" --columns "testcase1,testcase2,key,summary,labels,Subtasks,Business Value,custom three,custom-group-picker,custom-multi-user-picker,custom-user-picker,custom-versions,custom-multi-select,Story Points,testcase1,testcase2,last comment"`|`jira.get_issue_list(jql: "key = ZCUSTOM-4", output_format: "2", columns: "testcase1,testcase2,key,summary,labels,Subtasks,Business Value,custom three,custom-group-picker,custom-multi-user-picker,custom-user-picker,custom-versions,custom-multi-select,Story Points,testcase1,testcase2,last comment")`|
|`jira --action "getIssueList" --jql "key = ZCUSTOM-4" --outputFormat "4" --columns "testcase1,testcase2,key,summary,labels,Subtasks,Business Value,custom three,custom-group-picker,custom-multi-user-picker,custom-user-picker,custom-versions,custom-multi-select,Story Points,testcase1,testcase2,last comment"`|`jira.get_issue_list(jql: "key = ZCUSTOM-4", output_format: "4", columns: "testcase1,testcase2,key,summary,labels,Subtasks,Business Value,custom three,custom-group-picker,custom-multi-user-picker,custom-user-picker,custom-versions,custom-multi-select,Story Points,testcase1,testcase2,last comment")`|
|`jira --action "getIssueList" --jql "key = ZCUSTOM-4" --outputFormat "5" --columns "testcase1,testcase2,key,summary,labels,Subtasks,Business Value,custom three,custom-group-picker,custom-multi-user-picker,custom-user-picker,custom-versions,custom-multi-select,Story Points,testcase1,testcase2,last comment"`|`jira.get_issue_list(jql: "key = ZCUSTOM-4", output_format: "5", columns: "testcase1,testcase2,key,summary,labels,Subtasks,Business Value,custom three,custom-group-picker,custom-multi-user-picker,custom-user-picker,custom-versions,custom-multi-select,Story Points,testcase1,testcase2,last comment")`|
|`jira --action "getIssueList" --jql "key = ZCUSTOM-4" --outputFormat "999" --columns "testcase1,testcase2,key,summary,labels,Subtasks,Business Value,custom three,custom-group-picker,custom-multi-user-picker,custom-user-picker,custom-versions,custom-multi-select,Story Points,testcase1,testcase2,last comment"`|`jira.get_issue_list(jql: "key = ZCUSTOM-4", output_format: "999", columns: "testcase1,testcase2,key,summary,labels,Subtasks,Business Value,custom three,custom-group-picker,custom-multi-user-picker,custom-user-picker,custom-versions,custom-multi-select,Story Points,testcase1,testcase2,last comment")`|
|`jira --action "getIssueList" --jql "parent = ZCLICLONE-11 and summary ~ 'Subtask 1'"`|`jira.get_issue_list(jql: "parent = ZCLICLONE-11 and summary ~ 'Subtask 1'")`|
|`jira --action "getIssueList" --jql "project = ZCLICLONEX and type = 'improvement'" --limit "1"`|`jira.get_issue_list(jql: "project = ZCLICLONEX and type = 'improvement'", limit: "1")`|
|`jira --action "getIssueList" --jql "project = ZCLICLONEZ and issuetype in subTaskIssueTypes()"`|`jira.get_issue_list(jql: "project = ZCLICLONEZ and issuetype in subTaskIssueTypes()")`|
|`jira --action "getIssueList" --jql "project = 'zcustom'" --outputFormat "999"`|`jira.get_issue_list(jql: "project = 'zcustom'", output_format: "999")`|
|`jira --action "getIssueList" --jql "project = zjiracliA and type = 'improvement'" --limit "2"`|`jira.get_issue_list(jql: "project = zjiracliA and type = 'improvement'", limit: "2")`|
|`jira --action "getIssueList" --jql "project = 'zjiracli' and labels != null" --outputFormat "999"`|`jira.get_issue_list(jql: "project = 'zjiracli' and labels != null", output_format: "999")`|
|`jira --action "getIssueList" --jql "project = 'zjiracli' order by key desc" --outputFormat "4" --dateFormat "yyyy-MM-dd"`|`jira.get_issue_list(jql: "project = 'zjiracli' order by key desc", output_format: "4", date_format: "yyyy-MM-dd")`|
|`jira --action "getIssueList" --jql "project = 'zjiracli'" --outputFormat "999" --columns "key,2,custom1,custom2,description,"`|`jira.get_issue_list(jql: "project = 'zjiracli'", output_format: "999", columns: "key,2,custom1,custom2,description,")`|
|`jira --action "getIssueList" --jql "project = 'zjiracli'" --outputFormat "999" --dateFormat "yyyy.MM.dd" --columns "key,created,last comment user, last comment date, last comment"`|`jira.get_issue_list(jql: "project = 'zjiracli'", output_format: "999", date_format: "yyyy.MM.dd", columns: "key,created,last comment user, last comment date, last comment")`|
|`jira --action "getIssueList" --jql "project = zlinks and issue in linkedIssues(ZLINKS-1, 'duplicates')"`|`jira.get_issue_list(jql: "project = zlinks and issue in linkedIssues(ZLINKS-1, 'duplicates')")`|
|`jira --action "getIssueList" --jql "project = zlinks and issue in linkedIssues(ZLINKS-1, 'duplicates')" --outputFormat "999"`|`jira.get_issue_list(jql: "project = zlinks and issue in linkedIssues(ZLINKS-1, 'duplicates')", output_format: "999")`|
|`jira --action "getIssueList" --jql "project = 'zlinks'" --outputFormat "998" --dateFormat "yyyy-MM-dd"`|`jira.get_issue_list(jql: "project = 'zlinks'", output_format: "998", date_format: "yyyy-MM-dd")`|
|`jira --action "getIssueList" --jql "project = ZRUNNER and labels = 'fieldValues'" --outputFormat "2"`|`jira.get_issue_list(jql: "project = ZRUNNER and labels = 'fieldValues'", output_format: "2")`|
|`jira --action "getIssueList" --project "ZAGILEC" --dateFormat "yyyy-MM-dd HH:mm:ss.SSS" --outputFormat "2" --suppressId --columns "Key,Summary,Epic Link"`|`jira.get_issue_list(project: "ZAGILEC", date_format: "yyyy-MM-dd HH:mm:ss.SSS", output_format: "2", suppress_id: true, columns: "Key,Summary,Epic Link")`|
|`jira --action "getIssueList" --project "zjiracli" --file "target/output/jiracli/getIssueListProject.txt" --outputFormat "101"`|`jira.get_issue_list(project: "zjiracli", file: "target/output/jiracli/getIssueListProject.txt", output_format: "101")`|
|`jira --action "getIssueList" --search "key = ZCUSTOM-4" --outputFormat "2" --columns "testcase1,testcase2,key,summary,labels,Subtasks,Business Value,custom three,custom-group-picker,custom-multi-user-picker,custom-user-picker,custom-versions,custom-multi-select,Story Points,testcase1,testcase2,last comment"`|`jira.get_issue_list(search: "key = ZCUSTOM-4", output_format: "2", columns: "testcase1,testcase2,key,summary,labels,Subtasks,Business Value,custom three,custom-group-picker,custom-multi-user-picker,custom-user-picker,custom-versions,custom-multi-select,Story Points,testcase1,testcase2,last comment")`|
|`jira --action "getIssueList" --search "key = ZCUSTOM-4" --outputFormat "4" --columns "testcase1,testcase2,key,summary,labels,Subtasks,Business Value,custom three,custom-group-picker,custom-multi-user-picker,custom-user-picker,custom-versions,custom-multi-select,Story Points,testcase1,testcase2,last comment"`|`jira.get_issue_list(search: "key = ZCUSTOM-4", output_format: "4", columns: "testcase1,testcase2,key,summary,labels,Subtasks,Business Value,custom three,custom-group-picker,custom-multi-user-picker,custom-user-picker,custom-versions,custom-multi-select,Story Points,testcase1,testcase2,last comment")`|
|`jira --action "getIssueList" --search "key = ZCUSTOM-4" --outputFormat "5" --columns "testcase1,testcase2,key,summary,labels,Subtasks,Business Value,custom three,custom-group-picker,custom-multi-user-picker,custom-user-picker,custom-versions,custom-multi-select,Story Points,testcase1,testcase2,last comment"`|`jira.get_issue_list(search: "key = ZCUSTOM-4", output_format: "5", columns: "testcase1,testcase2,key,summary,labels,Subtasks,Business Value,custom three,custom-group-picker,custom-multi-user-picker,custom-user-picker,custom-versions,custom-multi-select,Story Points,testcase1,testcase2,last comment")`|
|`jira --action "getIssueList" --search "key = ZCUSTOM-4" --outputFormat "999" --columns "testcase1,testcase2,key,summary,labels,Subtasks,Business Value,custom three,custom-group-picker,custom-multi-user-picker,custom-user-picker,custom-versions,custom-multi-select,Story Points,testcase1,testcase2,last comment"`|`jira.get_issue_list(search: "key = ZCUSTOM-4", output_format: "999", columns: "testcase1,testcase2,key,summary,labels,Subtasks,Business Value,custom three,custom-group-picker,custom-multi-user-picker,custom-user-picker,custom-versions,custom-multi-select,Story Points,testcase1,testcase2,last comment")`|
|`jira --action "getIssue" --project "ZCLICLONE" --issue "ZCLICLONE-15"`|`jira.get_issue(project: "ZCLICLONE", issue: "ZCLICLONE-15")`|
|`jira --action "getIssue" --project "ZCLICLONE" --issue "ZCLICLONE-2"`|`jira.get_issue(project: "ZCLICLONE", issue: "ZCLICLONE-2")`|
|`jira --action "getIssueSecuritySchemeList"`|`jira.get_issue_security_scheme_list`|
|`jira --action "getIssueSecuritySchemeList" --options "deleteEnabled"`|`jira.get_issue_security_scheme_list(options: "deleteEnabled")`|
|`jira --action "getIssueTypeList"`|`jira.get_issue_type_list`|
|`jira --action "getIssueTypeList" --project "@all"`|`jira.get_issue_type_list(project: "@all")`|
|`jira --action "getIssueTypeList" --project "ZPROJECT"`|`jira.get_issue_type_list(project: "ZPROJECT")`|
|`jira --action "getIssueTypeSchemeList"`|`jira.get_issue_type_scheme_list`|
|`jira --action "getIssueTypeSchemeList" --options "deleteEnabled"`|`jira.get_issue_type_scheme_list(options: "deleteEnabled")`|
|`jira --action "getIssueTypeScreenSchemeList"`|`jira.get_issue_type_screen_scheme_list`|
|`jira --action "getIssueTypeScreenSchemeList" --options "deleteEnabled"`|`jira.get_issue_type_screen_scheme_list(options: "deleteEnabled")`|
|`jira --action "getLinkList" --issue "ZLINKS-1"`|`jira.get_link_list(issue: "ZLINKS-1")`|
|`jira --action "getLinkList" --issue "ZLINKS-1" --regex "duplicate"`|`jira.get_link_list(issue: "ZLINKS-1", regex: "duplicate")`|
|`jira --action "getLinkList" --issue "ZLINKS-2"`|`jira.get_link_list(issue: "ZLINKS-2")`|
|`jira --action "getLinkList" --jql "parent = ZLINKS-1 or key = ZLINKS-1 order by key"`|`jira.get_link_list(jql: "parent = ZLINKS-1 or key = ZLINKS-1 order by key")`|
|`jira --action "getLinkTypeList"`|`jira.get_link_type_list`|
|`jira --action "getLoginInfo" --dateFormat "yyyy-MM-dd HH:mm:ss"`|`jira.get_login_info(date_format: "yyyy-MM-dd HH:mm:ss")`|
|`jira --action "getNotificationSchemeList"`|`jira.get_notification_scheme_list`|
|`jira --action "getNotificationSchemeList" --options "deleteEnabled"`|`jira.get_notification_scheme_list(options: "deleteEnabled")`|
|`jira --action "getPermissionSchemeList"`|`jira.get_permission_scheme_list`|
|`jira --action "getPermissionSchemeList" --options "deleteEnabled"`|`jira.get_permission_scheme_list(options: "deleteEnabled")`|
|`jira --action "getProjectCategoryList"`|`jira.get_project_category_list`|
|`jira --action "getProjectList" --category "" --regex "ZPROJECT.*" --columns "key"`|`jira.get_project_list(category: "", regex: "ZPROJECT.*", columns: "key")`|
|`jira --action "getProjectList" --file "target/output/jiracli/getProjectListClone.txt" --outputFormat "2"`|`jira.get_project_list(file: "target/output/jiracli/getProjectListClone.txt", output_format: "2")`|
|`jira --action "getProjectList" --file "target/output/jiracliproject/getProjectList.txt"`|`jira.get_project_list(file: "target/output/jiracliproject/getProjectList.txt")`|
|`jira --action "getProjectList" --lead "developer" --lookup --regex "ZPROJECT.*"`|`jira.get_project_list(lead: "developer", lookup: true, regex: "ZPROJECT.*")`|
|`jira --action "getProjectList" --regex "ZPROJECT" --outputFormat "999"`|`jira.get_project_list(regex: "ZPROJECT", output_format: "999")`|
|`jira --action "getProject" --project "ZCLICLONET"`|`jira.get_project(project: "ZCLICLONET")`|
|`jira --action "getProject" --project "ZCLICLONEX"`|`jira.get_project(project: "ZCLICLONEX")`|
|`jira --action "getProject" --project "ZCLICLONEY"`|`jira.get_project(project: "ZCLICLONEY")`|
|`jira --action "getProject" --project "zjiracli"`|`jira.get_project(project: "zjiracli")`|
|`jira --action "getProject" --project "zjiracliD"`|`jira.get_project(project: "zjiracliD")`|
|`jira --action "getProject" --project "zjiracliX"`|`jira.get_project(project: "zjiracliX")`|
|`jira --action "getProject" --project "zjiracliX" --suppressId`|`jira.get_project(project: "zjiracliX", suppress_id: true)`|
|`jira --action "getProject" --project "ZPROJECT"`|`jira.get_project(project: "ZPROJECT")`|
|`jira --action "getProject" --project "ZPROJECTX"`|`jira.get_project(project: "ZPROJECTX")`|
|`jira --action "getProjectRoleActorList" --project "zjiracliB" --role "users"`|`jira.get_project_role_actor_list(project: "zjiracliB", role: "users")`|
|`jira --action "getProjectRoleActorList" --project "ZROLES" --role "@all" --outputFormat "2"`|`jira.get_project_role_actor_list(project: "ZROLES", role: "@all", output_format: "2")`|
|`jira --action "getProjectRoleActorList" --project "ZROLES" --role "users"`|`jira.get_project_role_actor_list(project: "ZROLES", role: "users")`|
|`jira --action "getProjectRoleByUserList" --userId "@all" --columns "User,Project,Administrators,Developers,Users,View" --regex "ZROLES"`|`jira.get_project_role_by_user_list(user_id: "@all", columns: "User,Project,Administrators,Developers,Users,View", regex: "ZROLES")`|
|`jira --action "getProjectRoleByUserList" --userId "automation" --columns "User,Project,Administrators,Developers,Users,View" --regex "ZROLES.*"`|`jira.get_project_role_by_user_list(user_id: "automation", columns: "User,Project,Administrators,Developers,Users,View", regex: "ZROLES.*")`|
|`jira --action "getProjectRoleList"`|`jira.get_project_role_list`|
|`jira --action "getProjectRoleList" --regex "zAdd project role test.*"`|`jira.get_project_role_list(regex: "zAdd project role test.*")`|
|`jira --action "getScreenList"`|`jira.get_screen_list`|
|`jira --action "getScreenList" --options "deleteEnabled"`|`jira.get_screen_list(options: "deleteEnabled")`|
|`jira --action "getScreenList" --regex "(?i).*default.*"`|`jira.get_screen_list(regex: "(?i).*default.*")`|
|`jira --action "getScreenSchemeList"`|`jira.get_screen_scheme_list`|
|`jira --action "getScreenSchemeList" --options "deleteEnabled"`|`jira.get_screen_scheme_list(options: "deleteEnabled")`|
|`jira --action "getSecurityLevelList" --project "zjiracli"`|`jira.get_security_level_list(project: "zjiracli")`|
|`jira --action "getSecurityLevelList" --project "zjiracliB"`|`jira.get_security_level_list(project: "zjiracliB")`|
|`jira --action "getServerInfo" --dateFormat "yyyy-MM-dd"`|`jira.get_server_info(date_format: "yyyy-MM-dd")`|
|`jira --action "getServerInfo" --debug`|`jira.get_server_info(debug: true)`|
|`jira --action "getServerInfo" --outputFormat "2" --dateFormat "yyyy-MM-dd HH:mm"`|`jira.get_server_info(output_format: "2", date_format: "yyyy-MM-dd HH:mm")`|
|`jira --action "getServerInfo" --outputFormat "999"`|`jira.get_server_info(output_format: "999")`|
|`jira --action "getStatusList"`|`jira.get_status_list`|
|`jira --action "getStatusList" --project "zjiracli"`|`jira.get_status_list(project: "zjiracli")`|
|`jira --action "getTransitionList" --issue "ZJIRACLI-3"`|`jira.get_transition_list(issue: "ZJIRACLI-3")`|
|`jira --action "getTransitionList" --issue "ZJIRACLI-3" --outputFormat "2"`|`jira.get_transition_list(issue: "ZJIRACLI-3", output_format: "2")`|
|`jira --action "getUserList" --group "jira-users" --regex "testuser1" --outputFormat "999"`|`jira.get_user_list(group: "jira-users", regex: "testuser1", output_format: "999")`|
|`jira --action "getUserList" --group "testgroup2"`|`jira.get_user_list(group: "testgroup2")`|
|`jira --action "getUserList" --group "testgroup2" --outputFormat "2"`|`jira.get_user_list(group: "testgroup2", output_format: "2")`|
|`jira --action "getUserList" --name "@all"`|`jira.get_user_list(name: "@all")`|
|`jira --action "getUserList" --name "@all" --regex ".*@x.com"`|`jira.get_user_list(name: "@all", regex: ".*@x.com")`|
|`jira --action "getUserList" --name "testuser" --outputFormat "1"`|`jira.get_user_list(name: "testuser", output_format: "1")`|
|`jira --action "getUserList" --name "testuser" --outputFormat "2"`|`jira.get_user_list(name: "testuser", output_format: "2")`|
|`jira --action "getUserList" --project "zuser" --role "developers"`|`jira.get_user_list(project: "zuser", role: "developers")`|
|`jira --action "getUser" --userId "Testuser3"`|`jira.get_user(user_id: "Testuser3")`|
|`jira --action "getUser" --userKey "testuser3"`|`jira.get_user(user_key: "testuser3")`|
|`jira --action "getVersionList" --project "zjiracli"`|`jira.get_version_list(project: "zjiracli")`|
|`jira --action "getVersionList" --project "zjiracli" --outputFormat "2"`|`jira.get_version_list(project: "zjiracli", output_format: "2")`|
|`jira --action "getVersionList" --project "zjiracli" --outputFormat "999" --dateFormat "yyyy.MM.dd"`|`jira.get_version_list(project: "zjiracli", output_format: "999", date_format: "yyyy.MM.dd")`|
|`jira --action "getVersion" --project "zjiracliA" --version "V1" --dateFormat "yyyy.MM.dd"`|`jira.get_version(project: "zjiracliA", version: "V1", date_format: "yyyy.MM.dd")`|
|`jira --action "getVersion" --project "zjiracliC" --version "V2" --outputFormat "999"`|`jira.get_version(project: "zjiracliC", version: "V2", output_format: "999")`|
|`jira --action "getVersion" --project "zjiracli" --name "V1" --dateFormat "yyyy MM dd"`|`jira.get_version(project: "zjiracli", name: "V1", date_format: "yyyy MM dd")`|
|`jira --action "getVersion" --project "zjiracli" --version "auto2" --dateFormat "yyyy.MM.dd"`|`jira.get_version(project: "zjiracli", version: "auto2", date_format: "yyyy.MM.dd")`|
|`jira --action "getVersion" --project "zjiracli" --version "V2" --dateFormat "yyyy.MM.dd"`|`jira.get_version(project: "zjiracli", version: "V2", date_format: "yyyy.MM.dd")`|
|`jira --action "getVersion" --project "zjiracli" --version "With Blanks"`|`jira.get_version(project: "zjiracli", version: "With Blanks")`|
|`jira --action "getVoterList" --issue "ZVOTEWATCH-1"`|`jira.get_voter_list(issue: "ZVOTEWATCH-1")`|
|`jira --action "getVoterList" --issue "ZVOTEWATCH-1" --outputFormat "2"`|`jira.get_voter_list(issue: "ZVOTEWATCH-1", output_format: "2")`|
|`jira --action "getVoterList" --issue "ZVOTEWATCH-1" --outputFormat "999"`|`jira.get_voter_list(issue: "ZVOTEWATCH-1", output_format: "999")`|
|`jira --action "getWatcherList" --issue "ZVOTEWATCH-1"`|`jira.get_watcher_list(issue: "ZVOTEWATCH-1")`|
|`jira --action "getWatcherList" --issue "ZVOTEWATCH-1" --outputFormat "2"`|`jira.get_watcher_list(issue: "ZVOTEWATCH-1", output_format: "2")`|
|`jira --action "getWatcherList" --issue "ZVOTEWATCH-1" --outputFormat "999"`|`jira.get_watcher_list(issue: "ZVOTEWATCH-1", output_format: "999")`|
|`jira --action "getWorkflowList" --dateFormat "yyyy-MM-dd" --regex "(Agile Simplified)|(jira)"`|`jira.get_workflow_list(date_format: "yyyy-MM-dd", regex: "(Agile Simplified)|(jira)")`|
|`jira --action "getWorkflow" --workflow "Agile Simplified" --dateFormat "yyyy-MM-dd"`|`jira.get_workflow(workflow: "Agile Simplified", date_format: "yyyy-MM-dd")`|
|`jira --action "getWorkList" --issue "ZWORK-1"`|`jira.get_work_list(issue: "ZWORK-1")`|
|`jira --action "getWorkList" --issue "ZWORK-1" --dateFormat "yyyy-MM-dd HH:mm:ss.SSS"`|`jira.get_work_list(issue: "ZWORK-1", date_format: "yyyy-MM-dd HH:mm:ss.SSS")`|
|`jira --action "import" --file "src/itest/resources/importProjects.json" --options "logFile=-"`|`jira.import(file: "src/itest/resources/importProjects.json", options: "logFile=-")`|
|`jira --action "linkIssue" --issue "249453" --toIssue "249454" --link "10011" --comment "Link comment"`|`jira.link_issue(issue: "249453", to_issue: "249454", link: "10011", comment: "Link comment")`|
|`jira --action "linkIssue" --issue "ZCLICLONE-4" --toIssue "ZCLICLONE-1" --link "relates"`|`jira.link_issue(issue: "ZCLICLONE-4", to_issue: "ZCLICLONE-1", link: "relates")`|
|`jira --action "linkIssue" --issue "ZLINKS-1" --toIssue "ZLINKS-2" --link "relates" --comment "Link comment"`|`jira.link_issue(issue: "ZLINKS-1", to_issue: "ZLINKS-2", link: "relates", comment: "Link comment")`|
|`jira --action "linkIssue" --issue "ZLINKS-1" --toIssue "ZLINKS-2" --link "relates" --comment "Link comment with group" --group "jira-users"`|`jira.link_issue(issue: "ZLINKS-1", to_issue: "ZLINKS-2", link: "relates", comment: "Link comment with group", group: "jira-users")`|
|`jira --action "linkIssue" --issue "ZLINKS-1" --toIssue "ZLINKS-2" --link "relates" --comment "Link comment with role and group" --role "Developers" --group "jira-users"`|`jira.link_issue(issue: "ZLINKS-1", to_issue: "ZLINKS-2", link: "relates", comment: "Link comment with role and group", role: "Developers", group: "jira-users")`|
|`jira --action "linkIssue" --issue "ZLINKS-1" --toIssue "ZLINKS-2" --link "relates" --comment "Link comment with role" --role "Developers"`|`jira.link_issue(issue: "ZLINKS-1", to_issue: "ZLINKS-2", link: "relates", comment: "Link comment with role", role: "Developers")`|
|`jira --action "linkIssue" --issue "ZLINKS-1" --toIssue "ZLINKS-3" --link "duplicate" --verbose`|`jira.link_issue(issue: "ZLINKS-1", to_issue: "ZLINKS-3", link: "duplicate", verbose: true)`|
|`jira --action "linkIssue" --issue "ZLINKS-1" --toIssue "ZLINKS-3" --link "relates"`|`jira.link_issue(issue: "ZLINKS-1", to_issue: "ZLINKS-3", link: "relates")`|
|`jira --action "linkIssue" --issue "ZSUB-1" --toIssue "ZSUB-2" --link "relates"`|`jira.link_issue(issue: "ZSUB-1", to_issue: "ZSUB-2", link: "relates")`|
|`jira --action "login" --outputFormat "2" --dateFormat "yyyy-MM-dd HH:mm:ss"`|`jira.login(output_format: "2", date_format: "yyyy-MM-dd HH:mm:ss")`|
|`jira --action "modifyFieldValue" --issue "ZFIELDS-4" --field "fixVersions" --field2 "components" --findReplace "'V2:V3,V4', C1:C2" --autoVersion --autoComponent`|`jira.modify_field_value(issue: "ZFIELDS-4", field: "fixVersions", field2: "components", find_replace: "'V2:V3,V4', C1:C2", auto_version: true, auto_component: true)`|
|`jira --action "modifyFieldValue" --issue "ZFIELDS-4" --field "summary" --field2 "environment" --findReplace "original:modified"`|`jira.modify_field_value(issue: "ZFIELDS-4", field: "summary", field2: "environment", find_replace: "original:modified")`|
|`jira --action "releaseVersion" --project "zjiracli" --name "V1" --continue`|`jira.release_version(project: "zjiracli", name: "V1", continue: true)`|
|`jira --action "releaseVersion" --project "zjiracli" --name "V1" --dateFormat "yyyy.MM.dd" --description "V1 description released"`|`jira.release_version(project: "zjiracli", name: "V1", date_format: "yyyy.MM.dd", description: "V1 description released")`|
|`jira --action "removeAttachment" --issue "ZATTACH-1" --id "63115"`|`jira.remove_attachment(issue: "ZATTACH-1", id: "63115")`|
|`jira --action "removeAttachment" --issue "ZATTACH-1" --name "data.txt"`|`jira.remove_attachment(issue: "ZATTACH-1", name: "data.txt")`|
|`jira --action "removeCustomField" --field "22507" --continue`|`jira.remove_custom_field(field: "22507", continue: true)`|
|`jira --action "removeCustomField" --field "customfield_22509" --continue`|`jira.remove_custom_field(field: "customfield_22509", continue: true)`|
|`jira --action "removeCustomField" --field "zzimport1" --type "com.atlassian.jira.plugin.system.customfieldtypes:textfield" --continue`|`jira.remove_custom_field(field: "zzimport1", type: "com.atlassian.jira.plugin.system.customfieldtypes:textfield", continue: true)`|
|`jira --action "removeCustomField" --field "zzz_Select List (single choice)" --continue`|`jira.remove_custom_field(field: "zzz_Select List (single choice)", continue: true)`|
|`jira --action "removeGroup" --group "bad"`|`jira.remove_group(group: "bad")`|
|`jira --action "removeGroup" --group "Testgroup1"`|`jira.remove_group(group: "Testgroup1")`|
|`jira --action "removeGroup" --group "testgroup2"`|`jira.remove_group(group: "testgroup2")`|
|`jira --action "removeLabels" --issue "ZJIRACLI-8" --labels "addLabel1 addLabel2"`|`jira.remove_labels(issue: "ZJIRACLI-8", labels: "addLabel1 addLabel2")`|
|`jira --action "removeLabels" --issue "ZJIRACLI-9" --labels "xxx"`|`jira.remove_labels(issue: "ZJIRACLI-9", labels: "xxx")`|
|`jira --action "removeProjectRoleActors" --project "zjiracli" --role "users" --userId "user, admin"`|`jira.remove_project_role_actors(project: "zjiracli", role: "users", user_id: "user, admin")`|
|`jira --action "removeProjectRoleActors" --project "ZROLES" --role "users" --userId "user, admin"`|`jira.remove_project_role_actors(project: "ZROLES", role: "users", user_id: "user, admin")`|
|`jira --action "removeProjectRoleActors" --project "ZROLESX" --role "users" --userId "user, admin"`|`jira.remove_project_role_actors(project: "ZROLESX", role: "users", user_id: "user, admin")`|
|`jira --action "removeProjectRole" --name "zAdd project role test" --continue`|`jira.remove_project_role(name: "zAdd project role test", continue: true)`|
|`jira --action "removeProjectRole" --name "zAdd project role test updated" --continue`|`jira.remove_project_role(name: "zAdd project role test updated", continue: true)`|
|`jira --action "removeUser" --userId "BAD"`|`jira.remove_user(user_id: "BAD")`|
|`jira --action "removeUser" --userId "testuser1"`|`jira.remove_user(user_id: "testuser1")`|
|`jira --action "removeUser" --userId "testuser1New"`|`jira.remove_user(user_id: "testuser1New")`|
|`jira --action "removeUser" --userId "testuser2"`|`jira.remove_user(user_id: "testuser2")`|
|`jira --action "removeUser" --userId "Testuser3"`|`jira.remove_user(user_id: "Testuser3")`|
|`jira --action "removeVote" --issue "ZVOTEWATCH-1" --user "developer" --password "asDeVqeTwsjtr4GnyKwf"`|`jira.remove_vote(issue: "ZVOTEWATCH-1", user: "developer", password: "asDeVqeTwsjtr4GnyKwf")`|
|`jira --action "removeWatchers" --issue "ZVOTEWATCH-1" --userId "invalid, xxxxxx" --continue`|`jira.remove_watchers(issue: "ZVOTEWATCH-1", user_id: "invalid, xxxxxx", continue: true)`|
|`jira --action "removeWatchers" --issue "ZVOTEWATCH-1" --userId "user, developer"`|`jira.remove_watchers(issue: "ZVOTEWATCH-1", user_id: "user, developer")`|
|`jira --action "removeWork" --issue "ZWORK-1" --id "32811"`|`jira.remove_work(issue: "ZWORK-1", id: "32811")`|
|`jira --action "renderRequest" --file "target/output/jiracli/renderRequestInvalidType.txt" --type "INVALID" --verbose`|`jira.render_request(file: "target/output/jiracli/renderRequestInvalidType.txt", type: "INVALID", verbose: true)`|
|`jira --action "renderRequest" --issue "ZJIRACLI-3" --file "target/output/jiracli/renderRequest.txt"`|`jira.render_request(issue: "ZJIRACLI-3", file: "target/output/jiracli/renderRequest.txt")`|
|`jira --action "renderRequest" --project "zjiracli" --file "target/output/jiracli/verifyProjectIssueTypeScreenScheme.txt" --request "plugins/servlet/project-config/ZJIRACLI/summary"`|`jira.render_request(project: "zjiracli", file: "target/output/jiracli/verifyProjectIssueTypeScreenScheme.txt", request: "plugins/servlet/project-config/ZJIRACLI/summary")`|
|`jira --action "renderRequest" --project "zjiracli" --file "target/output/jiracli/verifyUpdateProjectIssueTypeScreenSchemeDefault.txt" --request "plugins/servlet/project-config/ZJIRACLI/summary"`|`jira.render_request(project: "zjiracli", file: "target/output/jiracli/verifyUpdateProjectIssueTypeScreenSchemeDefault.txt", request: "plugins/servlet/project-config/ZJIRACLI/summary")`|
|`jira --action "renderRequest" --request "/rest/project-templates/1.0/templates" --type "FORM_URL_ENCODED" --acceptType "JSON" --verbose`|`jira.render_request(request: "/rest/project-templates/1.0/templates", type: "FORM_URL_ENCODED", accept_type: "JSON", verbose: true)`|
|`jira --action "run"`|`jira.run`|
|`jira --action "run" --common "--issue ZSUB-4"`|`jira.run(common: "--issue ZSUB-4")`|
|`jira --action "run" --file "-"`|`jira.run(file: "-")`|
|`jira --action "run" --file "src/itest/resources//renderRequest.txt" --findReplace "@project@:zjiracli"`|`jira.run(file: "src/itest/resources//renderRequest.txt", find_replace: "@project@:zjiracli")`|
|`jira --action "run" --file "src/itest/resources/runReplaceMapReference.txt" --common "--project ZRUNNER --labels JCLI528"`|`jira.run(file: "src/itest/resources/runReplaceMapReference.txt", common: "--project ZRUNNER --labels JCLI528")`|
|`jira --action "run" --file "src/itest/resources/runReplaceMap.txt" --common "--project ZRUNNER"`|`jira.run(file: "src/itest/resources/runReplaceMap.txt", common: "--project ZRUNNER")`|
|`jira --action "run" --file "src/itest/resources/run.txt"`|`jira.run(file: "src/itest/resources/run.txt")`|
|`jira --action "run" --file "src/itest/resources/runWithFindReplace.txt" --findReplace "##action##:getServerInfo"`|`jira.run(file: "src/itest/resources/runWithFindReplace.txt", find_replace: "##action##:getServerInfo")`|
|`jira --action "run" --file "target/output/jiracliexport2/exportDataProject.txt" --findReplace "--project ZEXPORT2:--project ZEXPORT2E" --findReplaceRegex "--name [^-]*:"`|`jira.run(file: "target/output/jiracliexport2/exportDataProject.txt", find_replace: "--project ZEXPORT2:--project ZEXPORT2E", find_replace_regex: "--name [^-]*:")`|
|`jira --action "runFromAttachmentList" --issue "ZRUNNER-1" --common "-a getAttachment --file ""target/output/jiraclirunner/Attachment-@attachment@"" --name @attachmentId@ --issue ZRUNNER-1"`|`jira.run_from_attachment_list(issue: "ZRUNNER-1", common: "-a getAttachment --file \"\"target/output/jiraclirunner/Attachment-@attachment@\"\" --name @attachmentId@ --issue ZRUNNER-1")`|
|`jira --action "runFromAttachmentList" --issue "ZRUNNER-1" --common "-a getAttachment --file ""target/output/jiraclirunner/Attachment-@attachment@"" --name @attachment@ --issue ZRUNNER-1"`|`jira.run_from_attachment_list(issue: "ZRUNNER-1", common: "-a getAttachment --file \"\"target/output/jiraclirunner/Attachment-@attachment@\"\" --name @attachment@ --issue ZRUNNER-1")`|
|`jira --action "runFromComponentList" --project "ZRUNNER" --common "-a getComponent --project ZRUNNER --version ""@component@""" --continue`|`jira.run_from_component_list(project: "ZRUNNER", common: "-a getComponent --project ZRUNNER --version \"\"@component@\"\"", continue: true)`|
|`jira --action "runFromCsv" --file "src/itest/resources/createUpdate.csv" --common "--project ZRUNNER"`|`jira.run_from_csv(file: "src/itest/resources/createUpdate.csv", common: "--project ZRUNNER")`|
|`jira --action "runFromCsv" --file "src/itest/resources/import2.csv" --propertyFile "src/itest/resources/import.properties" --common "--project ZRUNNER --action createIssue" --continue`|`jira.run_from_csv(file: "src/itest/resources/import2.csv", property_file: "src/itest/resources/import.properties", common: "--project ZRUNNER --action createIssue", continue: true)`|
|`jira --action "runFromCsv" --file "src/itest/resources/import.csv" --propertyFile "src/itest/resources/import.properties" --common "--project ZRUNNER" --continue`|`jira.run_from_csv(file: "src/itest/resources/import.csv", property_file: "src/itest/resources/import.properties", common: "--project ZRUNNER", continue: true)`|
|`jira --action "runFromCsv" --file "src/itest/resources/run2.csv" --common "-a createIssue --project ZRUNNER"`|`jira.run_from_csv(file: "src/itest/resources/run2.csv", common: "-a createIssue --project ZRUNNER")`|
|`jira --action "runFromCsv" --file "src/itest/resources/run.csv" --findReplace "@project@:ZRUNNER"`|`jira.run_from_csv(file: "src/itest/resources/run.csv", find_replace: "@project@:ZRUNNER")`|
|`jira --action "runFromCsv" --file "src/itest/resources/runFieldValues.csv" --common "--project ZRUNNER --action createIssue --type bug --summary xxx" --continue`|`jira.run_from_csv(file: "src/itest/resources/runFieldValues.csv", common: "--project ZRUNNER --action createIssue --type bug --summary xxx", continue: true)`|
|`jira --action "runFromCsv" --file "src/itest/resources//runIgnoreFields.csv" --propertyFile "src/itest/resources//runIgnoreFields.properties" --common "--project ZRUNNER --action createIssue"`|`jira.run_from_csv(file: "src/itest/resources//runIgnoreFields.csv", property_file: "src/itest/resources//runIgnoreFields.properties", common: "--project ZRUNNER --action createIssue")`|
|`jira --action "runFromCsv" --file "src/itest/resources/runsimple.csv" --common "--action getProject"`|`jira.run_from_csv(file: "src/itest/resources/runsimple.csv", common: "--action getProject")`|
|`jira --action "runFromCsv" --file "src/itest/resources/runUsingProperties.csv" --propertyFile "src/itest/resources/runUsingProperties.properties" --common "-a createIssue --project ZRUNNER"`|`jira.run_from_csv(file: "src/itest/resources/runUsingProperties.csv", property_file: "src/itest/resources/runUsingProperties.properties", common: "-a createIssue --project ZRUNNER")`|
|`jira --action "runFromFieldConfigurationList" --limit "2" --special "    #" --common "--action getClientInfo --reference @: @fieldConfiguration@# "`|`jira.run_from_field_configuration_list(limit: "2", special: "    #", common: "--action getClientInfo --reference @: @fieldConfiguration@# ")`|
|`jira --action "runFromFieldConfigurationSchemeList" --limit "2" --special "    #" --common "--action getClientInfo --reference @: @scheme@# "`|`jira.run_from_field_configuration_scheme_list(limit: "2", special: "    #", common: "--action getClientInfo --reference @: @scheme@# ")`|
|`jira --action "runFromFieldConfigurationSchemeList" --regex "ZCOPY" --common "--action deleteFieldConfigurationScheme --id @schemeId@" --options "deleteEnabled" --limit "10"`|`jira.run_from_field_configuration_scheme_list(regex: "ZCOPY", common: "--action deleteFieldConfigurationScheme --id @schemeId@", options: "deleteEnabled", limit: "10")`|
|`jira --action "runFromGroupList" --regex "group number .*" --common "-a removeGroup --group ~@group@~" --special "    ~"`|`jira.run_from_group_list(regex: "group number .*", common: "-a removeGroup --group ~@group@~", special: "    ~")`|
|`jira --action "runFromGroupList" --regex "jira.*" --limit "1" --common "-a getServerInfo --comment ~group: @group@~" --special "    ~"`|`jira.run_from_group_list(regex: "jira.*", limit: "1", common: "-a getServerInfo --comment ~group: @group@~", special: "    ~")`|
|`jira --action "runFromIssueList" --common '--action cloneIssue --issue @issue@ --toProject ZRUNNERC --description "Bulk clone example"' --search 'project = ZRUNNER and summary ~ "volume-*"'`|`jira.run_from_issue_list(common: "--action cloneIssue --issue @issue@ --toProject ZRUNNERC --description \"Bulk clone example\"", search: "project = ZRUNNER and summary ~ \"volume-*\"")`|
|`jira --action "runFromIssueList" --common "--action deleteIssue --issue @issue@  " --search 'project = ZRUNNER and summary ~ "volume-*"'`|`jira.run_from_issue_list(common: "--action deleteIssue --issue @issue@  ", search: "project = ZRUNNER and summary ~ \"volume-*\"")`|
|`jira --action "runFromIssueList" --file "-" --jql "project = 'zjiracli' and labels != null" --common "--action addLabels"`|`jira.run_from_issue_list(file: "-", jql: "project = 'zjiracli' and labels != null", common: "--action addLabels")`|
|`jira --action "runFromIssueList" --file "-" --jql "project = 'zjiracli' and labels != null" --common "--issue @issue@" --findReplace "##label##:done-by-action"`|`jira.run_from_issue_list(file: "-", jql: "project = 'zjiracli' and labels != null", common: "--issue @issue@", find_replace: "##label##:done-by-action")`|
|`jira --action "runFromIssueList" --jql "issuetype = Sub-task" --common "-a getIssue --issue @parent@ --comment issue:@issue@,id:@issueId@,project:@project@,projectId:@projectId@,parent:@parent@,parentId:@parentId@" --limit "1"`|`jira.run_from_issue_list(jql: "issuetype = Sub-task", common: "-a getIssue --issue @parent@ --comment issue:@issue@,id:@issueId@,project:@project@,projectId:@projectId@,parent:@parent@,parentId:@parentId@", limit: "1")`|
|`jira --action "runFromIssueList" --jql "project in (ZJIRACLI)" --common "-a getAttachmentList --outputFormat "999" --issue ""@issue@"" --file target/output/jiracliproject/attachmentList.csv --append" --continue`|`jira.run_from_issue_list(jql: "project in (ZJIRACLI)", common: "-a getAttachmentList --outputFormat \"999\" --issue \"\"@issue@\"\" --file target/output/jiracliproject/attachmentList.csv --append", continue: true)`|
|`jira --action "runFromIssueList" --jql "project in (ZJIRACLI)" --common "-a getLinkList --issue ""@issue@"" --file target/output/jiracliproject/linkList.csv --append" --continue`|`jira.run_from_issue_list(jql: "project in (ZJIRACLI)", common: "-a getLinkList --issue \"\"@issue@\"\" --file target/output/jiracliproject/linkList.csv --append", continue: true)`|
|`jira --action "runFromIssueList" --jql "project in (ZJIRACLI, ZHISTORY)" --common "-a getIssueHistoryList --issue ""@issue@"" --file target/output/jiracliproject/historyList.csv --dateFormat: yyyy-MM-dd_HH:mm:ss.SSS --append" --continue`|`jira.run_from_issue_list(jql: "project in (ZJIRACLI, ZHISTORY)", common: "-a getIssueHistoryList --issue \"\"@issue@\"\" --file target/output/jiracliproject/historyList.csv --dateFormat: yyyy-MM-dd_HH:mm:ss.SSS --append", continue: true)`|
|`jira --action "runFromIssueList" --jql "project in (ZWORK)" --common "-a getWorkList --outputFormat "999" --issue ""@issue@"" --file target/output/jiracliwork/workList.csv --append" --continue`|`jira.run_from_issue_list(jql: "project in (ZWORK)", common: "-a getWorkList --outputFormat \"999\" --issue \"\"@issue@\"\" --file target/output/jiracliwork/workList.csv --append", continue: true)`|
|`jira --action "runFromIssueList" --jql "project = 'zjiracli' and labels != null" --common "--action addLabels --issue @issue@ --labels done-by-action"`|`jira.run_from_issue_list(jql: "project = 'zjiracli' and labels != null", common: "--action addLabels --issue @issue@ --labels done-by-action")`|
|`jira --action "runFromIssueSecuritySchemeList" --limit "2" --special "    #" --common "--action getClientInfo --reference @: @scheme@# "`|`jira.run_from_issue_security_scheme_list(limit: "2", special: "    #", common: "--action getClientInfo --reference @: @scheme@# ")`|
|`jira --action "runFromIssueSecuritySchemeList" --regex "ZCOPY" --common "--action deleteIssueSecurityScheme --id @schemeId@" --options "deleteEnabled" --limit "10"`|`jira.run_from_issue_security_scheme_list(regex: "ZCOPY", common: "--action deleteIssueSecurityScheme --id @schemeId@", options: "deleteEnabled", limit: "10")`|
|`jira --action "runFromIssueTypeSchemeList" --limit "2" --special "    #" --common "--action getClientInfo --reference @: @scheme@# "`|`jira.run_from_issue_type_scheme_list(limit: "2", special: "    #", common: "--action getClientInfo --reference @: @scheme@# ")`|
|`jira --action "runFromIssueTypeSchemeList" --regex "ZCOPY" --common "--action deleteIssueTypeScheme --id @schemeId@" --options "deleteEnabled" --limit "10"`|`jira.run_from_issue_type_scheme_list(regex: "ZCOPY", common: "--action deleteIssueTypeScheme --id @schemeId@", options: "deleteEnabled", limit: "10")`|
|`jira --action "runFromIssueTypeScreenSchemeList" --limit "2" --special "    #" --common "--action getClientInfo --reference @: @scheme@# "`|`jira.run_from_issue_type_screen_scheme_list(limit: "2", special: "    #", common: "--action getClientInfo --reference @: @scheme@# ")`|
|`jira --action "runFromIssueTypeScreenSchemeList" --regex "ZCOPY" --common "--action deleteIssueTypeScreenScheme --id @schemeId@" --options "deleteEnabled" --limit "10"`|`jira.run_from_issue_type_screen_scheme_list(regex: "ZCOPY", common: "--action deleteIssueTypeScreenScheme --id @schemeId@", options: "deleteEnabled", limit: "10")`|
|`jira --action "runFromLinkList" --jql "parent = ZLINKS-1 or key = ZLINKS-1 order by key" --common "-a getClientInfo --options ~from: @fromIssue@, to: @toIssue@, type: @linkType@, typeId: @linkTypeId@, description: @linkDescription@, id: @linkId@~" --special "    ~"`|`jira.run_from_link_list(jql: "parent = ZLINKS-1 or key = ZLINKS-1 order by key", common: "-a getClientInfo --options ~from: @fromIssue@, to: @toIssue@, type: @linkType@, typeId: @linkTypeId@, description: @linkDescription@, id: @linkId@~", special: "    ~")`|
|`jira --action "runFromLinkList" --options "outward" --regex "relates" --jql "parent = ZLINKS-1 or key = ZLINKS-1 order by key" --common "-a getClientInfo --options ~from: @fromIssue@, to: @toIssue@, type: @linkType@, typeId: @linkTypeId@, description: @linkDescription@, id: @linkId@~" --special "    ~"`|`jira.run_from_link_list(options: "outward", regex: "relates", jql: "parent = ZLINKS-1 or key = ZLINKS-1 order by key", common: "-a getClientInfo --options ~from: @fromIssue@, to: @toIssue@, type: @linkType@, typeId: @linkTypeId@, description: @linkDescription@, id: @linkId@~", special: "    ~")`|
|`jira --action "runFromList" --list "1, 2, 3" --common "--action createIssue --project ZRUNNER --type task --summary volume-@entry@ "`|`jira.run_from_list(list: "1, 2, 3", common: "--action createIssue --project ZRUNNER --type task --summary volume-@entry@ ")`|
|`jira --action "runFromList" --list "aaa" --common "--action getServerInfo" --debug`|`jira.run_from_list(list: "aaa", common: "--action getServerInfo", debug: true)`|
|`jira --action "runFromList" --list "A,B" --common "-a getProject --project ZRUNNER --cookies target/output/jiraclirunner/cookiesBoth.txt -v" --cookies "target/output/jiraclirunner/parentCookiesBoth.txt" --verbose`|`jira.run_from_list(list: "A,B", common: "-a getProject --project ZRUNNER --cookies target/output/jiraclirunner/cookiesBoth.txt -v", cookies: "target/output/jiraclirunner/parentCookiesBoth.txt", verbose: true)`|
|`jira --action "runFromList" --list "A,B" --common "-a getProject --project ZRUNNER --cookies target/output/jiraclirunner/cookies.txt -v" --verbose`|`jira.run_from_list(list: "A,B", common: "-a getProject --project ZRUNNER --cookies target/output/jiraclirunner/cookies.txt -v", verbose: true)`|
|`jira --action "runFromList" --list "A,B" --common "-a getProject --project ZRUNNER -v" --cookies "target/output/jiraclirunner/parentCookies.txt" --verbose`|`jira.run_from_list(list: "A,B", common: "-a getProject --project ZRUNNER -v", cookies: "target/output/jiraclirunner/parentCookies.txt", verbose: true)`|
|`jira --action "runFromList" --list "a" --common "--issue ZSUB-4 --action setFieldValue --field environment --value ""%original_description%"""`|`jira.run_from_list(list: "a", common: "--issue ZSUB-4 --action setFieldValue --field environment --value \"\"%original_description%\"\"")`|
|`jira --action "runFromList" --list "Client, Server" --common "-a get@entry@Info"`|`jira.run_from_list(list: "Client, Server", common: "-a get@entry@Info")`|
|`jira --action "runFromList" --list "custom, Default Issue Type Scheme, custom," --continue --common '-a updateProject --project ZRUNNER --issueTypeScheme "@entry@"'`|`jira.run_from_list(list: "custom, Default Issue Type Scheme, custom,", continue: true, common: "-a updateProject --project ZRUNNER --issueTypeScheme \"@entry@\"")`|
|`jira --action "runFromList" --list "NOT_FOUND, ZRUNNER" --common "-a getProjectList --regex @entry@ --append -f target/output/jiraclirunner/runFromListAppend.txt" --clearFileBeforeAppend`|`jira.run_from_list(list: "NOT_FOUND, ZRUNNER", common: "-a getProjectList --regex @entry@ --append -f target/output/jiraclirunner/runFromListAppend.txt", clear_file_before_append: true)`|
|`jira --action "runFromList" --list "xxx, yyy" --common "--action runFromProjectList --regex ~(?i)jira|ZRUNNER~ --common ~--action getProject --project @project@ --comment @entry@ ~" --special "    ~"`|`jira.run_from_list(list: "xxx, yyy", common: "--action runFromProjectList --regex ~(?i)jira|ZRUNNER~ --common ~--action getProject --project @project@ --comment @entry@ ~", special: "    ~")`|
|`jira --action "runFromNotificationSchemeList" --limit "2" --special "    #" --common "--action getClientInfo --reference @: @scheme@# "`|`jira.run_from_notification_scheme_list(limit: "2", special: "    #", common: "--action getClientInfo --reference @: @scheme@# ")`|
|`jira --action "runFromNotificationSchemeList" --regex "ZCOPY" --common "--action deleteNotificationScheme --id @schemeId@" --options "deleteEnabled" --limit "10"`|`jira.run_from_notification_scheme_list(regex: "ZCOPY", common: "--action deleteNotificationScheme --id @schemeId@", options: "deleteEnabled", limit: "10")`|
|`jira --action "runFromPermissionSchemeList" --limit "2" --special "    #" --common "--action getClientInfo --reference @: @scheme@# "`|`jira.run_from_permission_scheme_list(limit: "2", special: "    #", common: "--action getClientInfo --reference @: @scheme@# ")`|
|`jira --action "runFromPermissionSchemeList" --regex "ZCOPY" --common "--action deletePermissionScheme --id @schemeId@" --options "deleteEnabled" --limit "10"`|`jira.run_from_permission_scheme_list(regex: "ZCOPY", common: "--action deletePermissionScheme --id @schemeId@", options: "deleteEnabled", limit: "10")`|
|`jira --action "runFromProjectList" --category "another" --common "-a getProject --project @project@"`|`jira.run_from_project_list(category: "another", common: "-a getProject --project @project@")`|
|`jira --action "runFromProjectList" --common "-a getProject --project ""@projectId@""" --continue --regex "ZRUNNER"`|`jira.run_from_project_list(common: "-a getProject --project \"\"@projectId@\"\"", continue: true, regex: "ZRUNNER")`|
|`jira --action "runFromProjectList" --common "-a getProject --project ""@project@""" --limit "5" --continue`|`jira.run_from_project_list(common: "-a getProject --project \"\"@project@\"\"", limit: "5", continue: true)`|
|`jira --action "runFromProjectList" --lead "developer" --regex "ZPROJECT.*" --common "-a getProject --project @project@"`|`jira.run_from_project_list(lead: "developer", regex: "ZPROJECT.*", common: "-a getProject --project @project@")`|
|`jira --action "runFromProjectList" --regex "ZJIRACLI.*|ZPROJECT" --common "-a getComponentList --outputFormat "999" --project ""@project@"" --file target/output/jiracliproject/componentList.csv --append" --continue`|`jira.run_from_project_list(regex: "ZJIRACLI.*|ZPROJECT", common: "-a getComponentList --outputFormat \"999\" --project \"\"@project@\"\" --file target/output/jiracliproject/componentList.csv --append", continue: true)`|
|`jira --action "runFromProjectList" --regex "ZJIRACLI.*|ZPROJECT" --common "-a getIssueTypeList --project ""@project@"" --file target/output/jiracliproject/issueTypeList.csv --append" --continue`|`jira.run_from_project_list(regex: "ZJIRACLI.*|ZPROJECT", common: "-a getIssueTypeList --project \"\"@project@\"\" --file target/output/jiracliproject/issueTypeList.csv --append", continue: true)`|
|`jira --action "runFromProjectList" --regex "ZJIRACLI.*|ZPROJECT" --common "-a getSecurityLevelList --outputFormat "999" --project ""@project@"" --file target/output/jiracliproject/securityLevelList.csv --append" --continue`|`jira.run_from_project_list(regex: "ZJIRACLI.*|ZPROJECT", common: "-a getSecurityLevelList --outputFormat \"999\" --project \"\"@project@\"\" --file target/output/jiracliproject/securityLevelList.csv --append", continue: true)`|
|`jira --action "runFromProjectList" --regex "ZJIRACLI.*|ZPROJECT" --common "-a getVersionList --outputFormat "999" --project ""@project@"" --file target/output/jiracliproject/versionList.csv --append" --continue`|`jira.run_from_project_list(regex: "ZJIRACLI.*|ZPROJECT", common: "-a getVersionList --outputFormat \"999\" --project \"\"@project@\"\" --file target/output/jiracliproject/versionList.csv --append", continue: true)`|
|`jira --action "runFromScreenList" --limit "2" --special "    #" --common "--action getClientInfo --reference @: @screen@# "`|`jira.run_from_screen_list(limit: "2", special: "    #", common: "--action getClientInfo --reference @: @screen@# ")`|
|`jira --action "runFromScreenSchemeList" --limit "2" --special "    #" --common "--action getClientInfo --reference @: @scheme@# "`|`jira.run_from_screen_scheme_list(limit: "2", special: "    #", common: "--action getClientInfo --reference @: @scheme@# ")`|
|`jira --action "runFromScreenSchemeList" --regex "ZCOPY" --common "--action deleteScreenScheme --id @schemeId@" --options "deleteEnabled" --limit "10"`|`jira.run_from_screen_scheme_list(regex: "ZCOPY", common: "--action deleteScreenScheme --id @schemeId@", options: "deleteEnabled", limit: "10")`|
|`jira --action "runFromUserList" --name "@all" --limit "2" --regex "((admin)|(automation))" --common "--action getServerInfo --comment @userId@"`|`jira.run_from_user_list(name: "@all", limit: "2", regex: "((admin)|(automation))", common: "--action getServerInfo --comment @userId@")`|
|`jira --action "runFromVersionList" --project "ZRUNNER" --common "-a getVersion --project @projectId@ --version ""@versionId@""" --continue --regex "V1"`|`jira.run_from_version_list(project: "ZRUNNER", common: "-a getVersion --project @projectId@ --version \"\"@versionId@\"\"", continue: true, regex: "V1")`|
|`jira --action "runFromVersionList" --project "ZRUNNER" --common "-a getVersion --project ZRUNNER --version ""@version@""" --continue`|`jira.run_from_version_list(project: "ZRUNNER", common: "-a getVersion --project ZRUNNER --version \"\"@version@\"\"", continue: true)`|
|`jira --action "runFromWorkflowList" --regex "((jira)|(Agile Simplified))" --limit "2" --file "-"`|`jira.run_from_workflow_list(regex: "((jira)|(Agile Simplified))", limit: "2", file: "-")`|
|`jira --action "runFromWorkflowSchemeList" --regex ".*Simplified.*" --limit "2" --file "-"`|`jira.run_from_workflow_scheme_list(regex: ".*Simplified.*", limit: "2", file: "-")`|
|`jira --action "runFromWorkflowSchemeList" --regex "ZCLICLONE.*" --common "--action deleteWorkflowScheme --id @schemeId@" --continue`|`jira.run_from_workflow_scheme_list(regex: "ZCLICLONE.*", common: "--action deleteWorkflowScheme --id @schemeId@", continue: true)`|
|`jira --action "setFieldValue" --issue "ZCUSTOM-1" --field "custom-cascade-select" --values "1 - A"`|`jira.set_field_value(issue: "ZCUSTOM-1", field: "custom-cascade-select", values: "1 - A")`|
|`jira --action "setFieldValue" --issue "ZCUSTOM-1" --field "custom-cascade-select" --values "2,B" --asCascadeSelect`|`jira.set_field_value(issue: "ZCUSTOM-1", field: "custom-cascade-select", values: "2,B", as_cascade_select: true)`|
|`jira --action "setFieldValue" --issue "ZCUSTOM-4" --field "custom-multi-select" --values "s1,s2,s3"`|`jira.set_field_value(issue: "ZCUSTOM-4", field: "custom-multi-select", values: "s1,s2,s3")`|
|`jira --action "setFieldValue" --issue "ZCUSTOM-7" --field "Story Points" --value ""`|`jira.set_field_value(issue: "ZCUSTOM-7", field: "Story Points", value: "")`|
|`jira --action "setFieldValue" --issue "ZFIELDS-1" --field "custom1" --values "The following should be on a new line: \n XXX"`|`jira.set_field_value(issue: "ZFIELDS-1", field: "custom1", values: "The following should be on a new line: \\n XXX")`|
|`jira --action "setFieldValue" --issue "ZFIELDS-1" --field "custom1" --values "'xxx,yyy'"`|`jira.set_field_value(issue: "ZFIELDS-1", field: "custom1", values: "'xxx,yyy'")`|
|`jira --action "setFieldValue" --issue "ZFIELDS-1" --field "custom1" --values "xxx,yyy"`|`jira.set_field_value(issue: "ZFIELDS-1", field: "custom1", values: "xxx,yyy")`|
|`jira --action "setFieldValue" --issue "ZFIELDS-1" --field "custom1" --value "The following should be on a new line: \n XXX"`|`jira.set_field_value(issue: "ZFIELDS-1", field: "custom1", value: "The following should be on a new line: \\n XXX")`|
|`jira --action "setFieldValue" --issue "ZFIELDS-1" --field "custom1" --value "xxx,yyy"`|`jira.set_field_value(issue: "ZFIELDS-1", field: "custom1", value: "xxx,yyy")`|
|`jira --action "setFieldValue" --issue "ZFIELDS-1" --field "custom-datetime" --value "21/10/1940 11:39:12" --dateFormat "dd/MM/yyyy HH:mm:ss"`|`jira.set_field_value(issue: "ZFIELDS-1", field: "custom-datetime", value: "21/10/1940 11:39:12", date_format: "dd/MM/yyyy HH:mm:ss")`|
|`jira --action "setFieldValue" --issue "ZFIELDS-1" --field "environment" --values "" --field2 "custom1" --values2 "xxx"`|`jira.set_field_value(issue: "ZFIELDS-1", field: "environment", values: "", field2: "custom1", values2: "xxx")`|
|`jira --action "setFieldValue" --issue "ZFIELDS-1" --file "src/itest/resources/data.txt" --field "environment" --appendText`|`jira.set_field_value(issue: "ZFIELDS-1", file: "src/itest/resources/data.txt", field: "environment", append_text: true)`|
|`jira --action "setFieldValue" --issue "ZFIELDS-2" --field "custom1" --values "append text" --appendText`|`jira.set_field_value(issue: "ZFIELDS-2", field: "custom1", values: "append text", append_text: true)`|
|`jira --action "setFieldValue" --issue "ZFIELDS-2" --field "custom-group-picker" --values "jira-users"`|`jira.set_field_value(issue: "ZFIELDS-2", field: "custom-group-picker", values: "jira-users")`|
|`jira --action "setFieldValue" --issue "ZFIELDS-2" --field "custom-multi-group-picker" --values "jira-users,jira-administrators"`|`jira.set_field_value(issue: "ZFIELDS-2", field: "custom-multi-group-picker", values: "jira-users,jira-administrators")`|
|`jira --action "setFieldValue" --issue "ZFIELDS-2" --field "custom-multi-select" --values "s1,s2"`|`jira.set_field_value(issue: "ZFIELDS-2", field: "custom-multi-select", values: "s1,s2")`|
|`jira --action "setFieldValue" --issue "ZFIELDS-2" --field "custom-multi-select" --values "s3" --append`|`jira.set_field_value(issue: "ZFIELDS-2", field: "custom-multi-select", values: "s3", append: true)`|
|`jira --action "setFieldValue" --issue "ZFIELDS-2" --field "custom-multi-user-picker" --values "automation"`|`jira.set_field_value(issue: "ZFIELDS-2", field: "custom-multi-user-picker", values: "automation")`|
|`jira --action "setFieldValue" --issue "ZFIELDS-2" --field "custom-user-picker" --values "automation"`|`jira.set_field_value(issue: "ZFIELDS-2", field: "custom-user-picker", values: "automation")`|
|`jira --action "setFieldValue" --issue "ZFIELDS-2" --file "src/itest/resources/data.txt" --field "custom1"`|`jira.set_field_value(issue: "ZFIELDS-2", file: "src/itest/resources/data.txt", field: "custom1")`|
|`jira --action "setFieldValue" --issue "ZFIELDS-3" --field "description" --verbose --value "aaa
 bbb"`|`jira.set_field_value(issue: "ZFIELDS-3", field: "description", verbose: true, value: "aaa\n bbb")`|
|`jira --action "setFieldValue" --issue "ZFIELDS-3" --field "priority" --verbose --value "blocker"`|`jira.set_field_value(issue: "ZFIELDS-3", field: "priority", verbose: true, value: "blocker")`|
|`jira --action "setFieldValue" --issue "ZFIELDS-3" --field "reporter" --verbose --value "automation"`|`jira.set_field_value(issue: "ZFIELDS-3", field: "reporter", verbose: true, value: "automation")`|
|`jira --action "setFieldValue" --issue "ZFIELDS-3" --field "summary" --verbose --value "xxx"`|`jira.set_field_value(issue: "ZFIELDS-3", field: "summary", verbose: true, value: "xxx")`|
|`jira --action "setFieldValue" --issue "ZFIELDS-3" --field "type" --verbose --value "sub-task2"`|`jira.set_field_value(issue: "ZFIELDS-3", field: "type", verbose: true, value: "sub-task2")`|
|`jira --action "setFieldValue" --issue "ZHISTORY-1" --field "custom-multi-select" --values "s1,s2"`|`jira.set_field_value(issue: "ZHISTORY-1", field: "custom-multi-select", values: "s1,s2")`|
|`jira --action "setFieldValue" --issue "ZJIRACLI-3" --field "custom-labels" --values "aaa,bbb"`|`jira.set_field_value(issue: "ZJIRACLI-3", field: "custom-labels", values: "aaa,bbb")`|
|`jira --action "setFieldValue" --issue "ZJIRACLI-3" --field "custom-labels" --values "aaa, ccc" --subtract`|`jira.set_field_value(issue: "ZJIRACLI-3", field: "custom-labels", values: "aaa, ccc", subtract: true)`|
|`jira --action "setFieldValue" --issue "ZJIRACLI-3" --field "custom-labels" --values "bbb" --subtract`|`jira.set_field_value(issue: "ZJIRACLI-3", field: "custom-labels", values: "bbb", subtract: true)`|
|`jira --action "setFieldValue" --issue "ZJIRACLI-3" --field "custom-labels" --values "ccc" --append`|`jira.set_field_value(issue: "ZJIRACLI-3", field: "custom-labels", values: "ccc", append: true)`|
|`jira --action "setFieldValue" --issue "ZJIRACLI-5" --field "custom-versions" --values "autoAppend" --asVersion --append --autoVersion`|`jira.set_field_value(issue: "ZJIRACLI-5", field: "custom-versions", values: "autoAppend", as_version: true, append: true, auto_version: true)`|
|`jira --action "setFieldValue" --issue "ZJIRACLI-5" --field "custom-versions" --values "V1, V2" --asVersion`|`jira.set_field_value(issue: "ZJIRACLI-5", field: "custom-versions", values: "V1, V2", as_version: true)`|
|`jira --action "setFieldValue" --issue "ZJIRACLI-5" --field "custom-versions" --values "V1, V2" --asVersion --append`|`jira.set_field_value(issue: "ZJIRACLI-5", field: "custom-versions", values: "V1, V2", as_version: true, append: true)`|
|`jira --action "setFieldValue" --issue "ZSUB-1" --field "custom-versions" --value "%original_fixVersions%" --field2 "description" --values2 "%original_description% - %original_fixVersions%"`|`jira.set_field_value(issue: "ZSUB-1", field: "custom-versions", value: "%original_fixVersions%", field2: "description", values2: "%original_description% - %original_fixVersions%")`|
|`jira --action "setShareScope" --value "global"`|`jira.set_share_scope(value: "global")`|
|`jira --action "transitionIssue" --issue "ZJIRACLI-3" --transition "5" --resolution "Fixed" --fixVersions "V1,  V2" --comment "I fixed this. \n It will be good now." --type "Bug" --continue --priority "Major" --reporter "automation" --affectsVersions "" --environment "" --components ""`|`jira.transition_issue(issue: "ZJIRACLI-3", transition: "5", resolution: "Fixed", fix_versions: "V1,  V2", comment: "I fixed this. \\n It will be good now.", type: "Bug", continue: true, priority: "Major", reporter: "automation", affects_versions: "", environment: "", components: "")`|
|`jira --action "transitionIssue" --issue "ZJIRACLI-3" --transition "Start Progress"`|`jira.transition_issue(issue: "ZJIRACLI-3", transition: "Start Progress")`|
|`jira --action "transitionIssue" --issue "ZSUB-3" --transition "Resolve Issue" --field "testcase1" --values "subtasks: %parent_subtasks%" --comment "subtasks: %parent_subtasks%"`|`jira.transition_issue(issue: "ZSUB-3", transition: "Resolve Issue", field: "testcase1", values: "subtasks: %parent_subtasks%", comment: "subtasks: %parent_subtasks%")`|
|`jira --action "unarchiveVersion" --project "zjiracli" --name "V1"`|`jira.unarchive_version(project: "zjiracli", name: "V1")`|
|`jira --action "unreleaseVersion" --project "zjiracli" --name "V1" --date "2015.12.31" --dateFormat "yyyy.MM.dd" --description "V1 description"`|`jira.unrelease_version(project: "zjiracli", name: "V1", date: "2015.12.31", date_format: "yyyy.MM.dd", description: "V1 description")`|
|`jira --action "updateComponent" --project "zjiracli" --component "C3First" --name "C3" --description "a generic description" --lead "automation" --defaultAssignee "project_lead"`|`jira.update_component(project: "zjiracli", component: "C3First", name: "C3", description: "a generic description", lead: "automation", default_assignee: "project_lead")`|
|`jira --action "updateComponent" --project "ZSUB" --component "C1" --description "C1 description"`|`jira.update_component(project: "ZSUB", component: "C1", description: "C1 description")`|
|`jira --action "updateComponent" --project "ZSUB" --component "C2" --description "C2 description"`|`jira.update_component(project: "ZSUB", component: "C2", description: "C2 description")`|
|`jira --action "updateFilter" --id "24903" --jql "project = ZFILTER AND resolution is EMPTY" --favorite`|`jira.update_filter(id: "24903", jql: "project = ZFILTER AND resolution is EMPTY", favorite: true)`|
|`jira --action "updateIssue" --issue "249564" --fixVersions "auto2" --autoVersion --append`|`jira.update_issue(issue: "249564", fix_versions: "auto2", auto_version: true, append: true)`|
|`jira --action "updateIssue" --issue "ZCUSTOM-1" --field "custom-cascade-select" --values "1,A" --asCascadeSelect`|`jira.update_issue(issue: "ZCUSTOM-1", field: "custom-cascade-select", values: "1,A", as_cascade_select: true)`|
|`jira --action "updateIssue" --issue "ZCUSTOM-4" --field "custom-multi-select" --values "s1,s2,s3"`|`jira.update_issue(issue: "ZCUSTOM-4", field: "custom-multi-select", values: "s1,s2,s3")`|
|`jira --action "updateIssue" --issue "ZFIELDS-1" --description "append text" --appendText`|`jira.update_issue(issue: "ZFIELDS-1", description: "append text", append_text: true)`|
|`jira --action "updateIssue" --issue "ZHISTORY-1" --summary "Updated summary" --description "Updated description" --field "custom1" --values "updated value"`|`jira.update_issue(issue: "ZHISTORY-1", summary: "Updated summary", description: "Updated description", field: "custom1", values: "updated value")`|
|`jira --action "updateIssue" --issue "ZJIRACLI-3" --affectsVersions "swap1" --fixVersions "swap2" --autoVersion`|`jira.update_issue(issue: "ZJIRACLI-3", affects_versions: "swap1", fix_versions: "swap2", auto_version: true)`|
|`jira --action "updateIssue" --issue "ZJIRACLI-3" --components "auto1" --autoComponent`|`jira.update_issue(issue: "ZJIRACLI-3", components: "auto1", auto_component: true)`|
|`jira --action "updateIssue" --issue "ZJIRACLI-3" --components "auto2" --autoComponent --append`|`jira.update_issue(issue: "ZJIRACLI-3", components: "auto2", auto_component: true, append: true)`|
|`jira --action "updateIssue" --issue "ZJIRACLI-3" --components "swap1" --autoComponent`|`jira.update_issue(issue: "ZJIRACLI-3", components: "swap1", auto_component: true)`|
|`jira --action "updateIssue" --issue "ZJIRACLI-3" --custom "custom1:zzz"`|`jira.update_issue(issue: "ZJIRACLI-3", custom: "custom1:zzz")`|
|`jira --action "updateIssue" --issue "ZJIRACLI-3" --date "27/Jan/10" --dateFormat "d/MMM/yy"`|`jira.update_issue(issue: "ZJIRACLI-3", date: "27/Jan/10", date_format: "d/MMM/yy")`|
|`jira --action "updateIssue" --issue "ZJIRACLI-3" --date "" --components "" --affectsVersions ""`|`jira.update_issue(issue: "ZJIRACLI-3", date: "", components: "", affects_versions: "")`|
|`jira --action "updateIssue" --issue "ZJIRACLI-3" --date "" --components "" --affectsVersions "" --fixVersions ""`|`jira.update_issue(issue: "ZJIRACLI-3", date: "", components: "", affects_versions: "", fix_versions: "")`|
|`jira --action "updateIssue" --issue "ZJIRACLI-3" --environment "x12345" --originalEstimate "3h" --comment "Added on updateIssue"`|`jira.update_issue(issue: "ZJIRACLI-3", environment: "x12345", original_estimate: "3h", comment: "Added on updateIssue")`|
|`jira --action "updateIssue" --issue "ZJIRACLI-3" --fixVersions "auto1" --autoVersion`|`jira.update_issue(issue: "ZJIRACLI-3", fix_versions: "auto1", auto_version: true)`|
|`jira --action "updateIssue" --issue "ZJIRACLI-5" --custom "custom-versions:," --component ""`|`jira.update_issue(issue: "ZJIRACLI-5", custom: "custom-versions:,", component: "")`|
|`jira --action "updateIssue" --issue "ZJIRACLI-5" --date ""`|`jira.update_issue(issue: "ZJIRACLI-5", date: "")`|
|`jira --action "updateIssue" --issue "ZJIRACLI-5" --date "2015*01*02" --dateFormat "yyyy*MM*dd"`|`jira.update_issue(issue: "ZJIRACLI-5", date: "2015*01*02", date_format: "yyyy*MM*dd")`|
|`jira --action "updateIssue" --issue "ZJIRACLI-5" --field "custom1" --values "xxxx"`|`jira.update_issue(issue: "ZJIRACLI-5", field: "custom1", values: "xxxx")`|
|`jira --action "updateIssue" --issue "ZJIRACLI-5" --field "custom2" --values ""`|`jira.update_issue(issue: "ZJIRACLI-5", field: "custom2", values: "")`|
|`jira --action "updateIssue" --issue "ZJIRACLI-8" --labels "label2 label3 label2 label3" --description "labels added"`|`jira.update_issue(issue: "ZJIRACLI-8", labels: "label2 label3 label2 label3", description: "labels added")`|
|`jira --action "updateIssue" --issue "ZJIRACLIB-2" --security ""`|`jira.update_issue(issue: "ZJIRACLIB-2", security: "")`|
|`jira --action "updateIssue" --issue "ZJIRACLIB-2" --security "developer-role"`|`jira.update_issue(issue: "ZJIRACLIB-2", security: "developer-role")`|
|`jira --action "updateIssue" --issue "ZSUB-1" --environment "%original_description%"`|`jira.update_issue(issue: "ZSUB-1", environment: "%original_description%")`|
|`jira --action "updateIssue" --issue "ZUSER-1" --reporter "automation"`|`jira.update_issue(issue: "ZUSER-1", reporter: "automation")`|
|`jira --action "updateIssue" --issue "ZUSER-1" --reporter "testuser2" --lookup`|`jira.update_issue(issue: "ZUSER-1", reporter: "testuser2", lookup: true)`|
|`jira --action "updateIssue" --issue "ZWORK-2" --estimate "2w 1d"`|`jira.update_issue(issue: "ZWORK-2", estimate: "2w 1d")`|
|`jira --action "updateIssue" --issue "ZWORK-2" --estimate "3w 1d" --summary "Updated"`|`jira.update_issue(issue: "ZWORK-2", estimate: "3w 1d", summary: "Updated")`|
|`jira --action "updateIssue" --issue "ZWORK-2" --originalEstimate "4w 2d"`|`jira.update_issue(issue: "ZWORK-2", original_estimate: "4w 2d")`|
|`jira --action "updateProject" --project "zjiracliC" --issueSecurityScheme "test restrictions" --notificationScheme "test" --permissionScheme "Restrict create issue"`|`jira.update_project(project: "zjiracliC", issue_security_scheme: "test restrictions", notification_scheme: "test", permission_scheme: "Restrict create issue")`|
|`jira --action "updateProject" --project "zjiracli" --issueTypeScheme "10000"`|`jira.update_project(project: "zjiracli", issue_type_scheme: "10000")`|
|`jira --action "updateProject" --project "zjiracli" --issueTypeScheme "Default Issue Type Scheme"`|`jira.update_project(project: "zjiracli", issue_type_scheme: "Default Issue Type Scheme")`|
|`jira --action "updateProject" --project "zjiracli" --issueTypeScheme "zclone"`|`jira.update_project(project: "zjiracli", issue_type_scheme: "zclone")`|
|`jira --action "updateProject" --project "zjiracli" --issueTypeScreenScheme "1"`|`jira.update_project(project: "zjiracli", issue_type_screen_scheme: "1")`|
|`jira --action "updateProject" --project "zjiracli" --issueTypeScreenScheme "Copy of default"`|`jira.update_project(project: "zjiracli", issue_type_screen_scheme: "Copy of default")`|
|`jira --action "updateProject" --project "zjiracli" --issueTypeScreenScheme "Default Issue Type Screen Scheme"`|`jira.update_project(project: "zjiracli", issue_type_screen_scheme: "Default Issue Type Screen Scheme")`|
|`jira --action "updateProject" --project "zjiracli" --workflowScheme "" --issueTypeScheme "" --fieldConfigurationScheme "" --issueTypeScreenScheme ""`|`jira.update_project(project: "zjiracli", workflow_scheme: "", issue_type_scheme: "", field_configuration_scheme: "", issue_type_screen_scheme: "")`|
|`jira --action "updateProject" --project "zjiracliX" --defaultAssignee "project_lead"`|`jira.update_project(project: "zjiracliX", default_assignee: "project_lead")`|
|`jira --action "updateProject" --project "zjiracliX" --defaultAssignee "unassigned"`|`jira.update_project(project: "zjiracliX", default_assignee: "unassigned")`|
|`jira --action "updateProject" --project "zjiracliX" --description "Updated description again"`|`jira.update_project(project: "zjiracliX", description: "Updated description again")`|
|`jira --action "updateProject" --project "zjiracliX" --description "Updated description" --issueSecurityScheme "test restrictions" --fieldConfigurationScheme "Description required" --notificationScheme "test" --verbose`|`jira.update_project(project: "zjiracliX", description: "Updated description", issue_security_scheme: "test restrictions", field_configuration_scheme: "Description required", notification_scheme: "test", verbose: true)`|
|`jira --action "updateProject" --project "ZPROJECT" --category ""`|`jira.update_project(project: "ZPROJECT", category: "")`|
|`jira --action "updateProject" --project "ZPROJECT" --category "another"`|`jira.update_project(project: "ZPROJECT", category: "another")`|
|`jira --action "updateProject" --project "ZPROJECT" --notificationScheme ""`|`jira.update_project(project: "ZPROJECT", notification_scheme: "")`|
|`jira --action "updateProject" --project "ZPROJECT" --notificationScheme "10000"`|`jira.update_project(project: "ZPROJECT", notification_scheme: "10000")`|
|`jira --action "updateProject" --project "ZPROJECT" --url "https://bobswift-test.atlassian.net"`|`jira.update_project(project: "ZPROJECT", url: "https://bobswift-test.atlassian.net")`|
|`jira --action "updateProjectRole" --role "zAdd project role test" --name "zAdd project role test updated"`|`jira.update_project_role(role: "zAdd project role test", name: "zAdd project role test updated")`|
|`jira --action "updateUserProperty" --userId "testuser1" --name "a b" --value " xxxx"`|`jira.update_user_property(user_id: "testuser1", name: "a b", value: " xxxx")`|
|`jira --action "updateUserProperty" --userId "testuser1" --name "testProperty" --value "test property value"`|`jira.update_user_property(user_id: "testuser1", name: "testProperty", value: "test property value")`|
|`jira --action "updateVersion" --project "zjiracliC" --version "V2" --description "NEW description" --startDate "2015-01-01" --date "2015-02-01" --dateFormat "yyyy-MM-dd"`|`jira.update_version(project: "zjiracliC", version: "V2", description: "NEW description", start_date: "2015-01-01", date: "2015-02-01", date_format: "yyyy-MM-dd")`|
|`jira --action "updateVersion" --project "zjiracli" --version "auto1" --after "-1"`|`jira.update_version(project: "zjiracli", version: "auto1", after: "-1")`|
|`jira --action "updateVersion" --project "zjiracli" --version "auto1" --after "auto2"`|`jira.update_version(project: "zjiracli", version: "auto1", after: "auto2")`|
|`jira --action "updateVersion" --project "zjiracli" --version "auto2" --after ""`|`jira.update_version(project: "zjiracli", version: "auto2", after: "")`|
|`jira --action "updateVersion" --project "zjiracli" --version "auto2" --date "" --dateFormat "yyyy/MM/dd"`|`jira.update_version(project: "zjiracli", version: "auto2", date: "", date_format: "yyyy/MM/dd")`|
|`jira --action "updateVersion" --project "zjiracli" --version "auto2" --description "updateVersion description" --startDate "2014/09/30" --date "2015/01/02/" --dateFormat "yyyy/MM/dd"`|`jira.update_version(project: "zjiracli", version: "auto2", description: "updateVersion description", start_date: "2014/09/30", date: "2015/01/02/", date_format: "yyyy/MM/dd")`|
|`jira --action "updateVersion" --project "zjiracli" --version "V1" --description "V1 description"`|`jira.update_version(project: "zjiracli", version: "V1", description: "V1 description")`|
|`jira --action "updateWork" --issue "ZWORK-1" --id "32811" --comment "Updated work log entry"`|`jira.update_work(issue: "ZWORK-1", id: "32811", comment: "Updated work log entry")`|
|`jira --action "updateWork" --issue "ZWORK-1" --id "32811" --timeSpent "1w" --autoAdjust`|`jira.update_work(issue: "ZWORK-1", id: "32811", time_spent: "1w", auto_adjust: true)`|
|`jira --action "updateWork" --issue "ZWORK-1" --id "32811" --userId "developer"`|`jira.update_work(issue: "ZWORK-1", id: "32811", user_id: "developer")`|
|`jira --action "validateLicense"`|`jira.validate_license`|

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/seanhuber/jira_cli.

## Attribution

Any and all credit is given to Bob Swift's JIRA Command Line adapter and client.  This gem is only a ruby wrapper around a well-documented, feature-rich, java-based utility: [JIRA Command Line Interface [Bob Swift Atlassian Add-on]](https://bobswift.atlassian.net/wiki/spaces/JCLI)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
