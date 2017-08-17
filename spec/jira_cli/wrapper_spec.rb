RSpec.describe JiraCli::Wrapper do
  it 'creates a new project' do
    jira = JiraCli::Wrapper.new
    output = "Project 'MYPROJ' created with key MYPROJ and id 12345."
    expect_cli_request("jira --action \"createProject\" --project \"MYPROJ\" --lead \"shuber\"", output, output) do
      jira.create_project key: 'MYPROJ', lead: 'shuber'
    end
  end

  it 'deletes an issue type scheme' do
    jira = JiraCli::Wrapper.new
    output = "Issue type scheme with id 123 deleted."
    expect_cli_request("jira --action \"deleteIssueTypeScheme\" --id \"123\"", output, output) do
      jira.delete_issue_type_scheme id: 123
    end
  end

  it 'deletes an issue type screen scheme' do
    jira = JiraCli::Wrapper.new
    output = "Issue type screen scheme with id 123 deleted."
    expect_cli_request("jira --action \"deleteIssueTypeScreenScheme\" --id \"123\"", output, output) do
      jira.delete_issue_type_screen_scheme id: 123
    end
  end

  it 'gets server info' do
    jira = JiraCli::Wrapper.new
    output = "JIRA version: 7.3.0, build: 73011, time: 1/3/17 12:00 AM, time zone: Central Standard Time, description: My Description, url: http://jira.<my_domain>.com"
    expect_cli_request("jira --action \"getServerInfo\"", output, output) do
      jira.get_server_info
    end
  end

  it 'gets workflow list' do
    cli_response = '5 workflows in list
"Name","Description","Last Modified","Last Modifier","Step Count","Default"
"jira","The default JIRA workflow.","","","5","Yes"
"PROJ1: Software Development Workflow","","02/27/2015 11:16 AM","Jane Doe","4","No"
"PROJ2: Software Development Workflow","","02/27/2015 11:26 AM","Jane Doe","4","No"
"PROJ3: Software Development Workflow","","02/27/2015 11:19 AM","Jane Doe","4","No"
"PROJ4: Software Development Workflow","","02/27/2015 11:37 AM","Jane Doe","4","No"'

    expected_result = {
                  "jira" => {
            :description => "The default JIRA workflow.",
             :step_count => 5,
                :default => "Yes"
      },
      "PROJ1: Software Development Workflow" => {
          :last_modified => "02/27/2015 11:16 AM",
          :last_modifier => "Jane Doe",
             :step_count => 4,
                :default => "No"
      },
      "PROJ2: Software Development Workflow" => {
          :last_modified => "02/27/2015 11:26 AM",
          :last_modifier => "Jane Doe",
             :step_count => 4,
                :default => "No"
      },
      "PROJ3: Software Development Workflow" => {
          :last_modified => "02/27/2015 11:19 AM",
          :last_modifier => "Jane Doe",
             :step_count => 4,
                :default => "No"
      },
      "PROJ4: Software Development Workflow" => {
          :last_modified => "02/27/2015 11:37 AM",
          :last_modifier => "Jane Doe",
             :step_count => 4,
                :default => "No"
      }
    }

    jira = JiraCli::Wrapper.new
    expect_cli_request("jira --action \"getWorkflowList\"", cli_response, expected_result) do
      jira.get_workflow_list
    end
  end

  it 'gets workflow scheme list' do
    cli_response = '7 workflow schemes in list
"Id","Name","Description","Delete Enabled","Projects"
"1001","PROJ1: Workflow Scheme","","No","ACCPAC"
"1002","PROJ2: Workflow Scheme","Generated by JIRA Software version 7.3.0-DAILY20161214023053. This workflow scheme is managed internally by JIRA Software. Do not manually modify this workflow scheme.","No","SSO,ADF,FMAP,TFORT"
"1003","PROJ3: Workflow Scheme","Generated by JIRA Software version 6.3.7. This workflow scheme is managed internally by JIRA Software. Do not manually modify this workflow scheme.","Yes",""
"1004","PROJ4: Workflow Scheme","Generated by JIRA Software version 6.3.0.2. This workflow scheme is managed internally by JIRA Software. Do not manually modify this workflow scheme.","No","SSP"
"1005","PROJ5: Workflow Scheme","","No","ANA"
"1006","PROJ6: Workflow Scheme","","No","APPEALS"
"1007","PROJ7: Workflow Scheme","","No","APPEALSETL"'

    expected_result = {
      1001 => {
                    :name => "PROJ1: Workflow Scheme",
          :delete_enabled => "No",
                :projects => "ACCPAC"
      },
      1002 => {
                    :name => "PROJ2: Workflow Scheme",
             :description => "Generated by JIRA Software version 7.3.0-DAILY20161214023053. This workflow scheme is managed internally by JIRA Software. Do not manually modify this workflow scheme.",
          :delete_enabled => "No",
                :projects => "SSO,ADF,FMAP,TFORT"
      },
      1003 => {
                    :name => "PROJ3: Workflow Scheme",
             :description => "Generated by JIRA Software version 6.3.7. This workflow scheme is managed internally by JIRA Software. Do not manually modify this workflow scheme.",
          :delete_enabled => "Yes"
      },
      1004 => {
                    :name => "PROJ4: Workflow Scheme",
             :description => "Generated by JIRA Software version 6.3.0.2. This workflow scheme is managed internally by JIRA Software. Do not manually modify this workflow scheme.",
          :delete_enabled => "No",
                :projects => "SSP"
      },
      1005 => {
                    :name => "PROJ5: Workflow Scheme",
          :delete_enabled => "No",
                :projects => "ANA"
      },
      1006 => {
                    :name => "PROJ6: Workflow Scheme",
          :delete_enabled => "No",
                :projects => "APPEALS"
      },
      1007 => {
                    :name => "PROJ7: Workflow Scheme",
          :delete_enabled => "No",
                :projects => "APPEALSETL"
      }
    }
    jira = JiraCli::Wrapper.new
    expect_cli_request("jira --action \"getWorkflowSchemeList\"", cli_response, expected_result) do
      results = jira.get_workflow_scheme_list
      # ap results
      results
    end
  end
end
