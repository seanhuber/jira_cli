RSpec.describe JiraCli::Wrapper do
  before(:all) do
    @jira = JiraCli::Wrapper.new
  end

  it 'creates a new project' do
    output = "Project 'MYPROJ' created with key MYPROJ and id 12345."
    expect_cli_request("jira --action \"createProject\" --project \"MYPROJ\" --lead \"shuber\"", output, output) do
      @jira.create_project key: 'MYPROJ', lead: 'shuber'
    end
  end

  it 'deletes an issue type scheme' do
    output = "Issue type scheme with id 123 deleted."
    expect_cli_request("jira --action \"deleteIssueTypeScheme\" --id \"123\"", output, output) do
      @jira.delete_issue_type_scheme id: 123
    end
  end

  it 'deletes an issue type screen scheme' do
    output = "Issue type screen scheme with id 123 deleted."
    expect_cli_request("jira --action \"deleteIssueTypeScreenScheme\" --id \"123\"", output, output) do
      @jira.delete_issue_type_screen_scheme id: 123
    end
  end

  it 'deletes a project' do
    output = "Project MYPROJ deleted."
    expect_cli_request("jira --action \"deleteProject\" --project \"MYPROJ\"", output, output) do
      @jira.delete_project key: 'MYPROJ'
    end
  end

  it 'deletes a screen' do
    output = "Screen with id 123 deleted."
    expect_cli_request("jira --action \"deleteScreen\" --id \"123\"", output, output) do
      @jira.delete_screen id: 123
    end
  end

  it 'deletes a screen scheme' do
    output = "Screen scheme with id 123 deleted."
    expect_cli_request("jira --action \"deleteScreenScheme\" --id \"123\"", output, output) do
      @jira.delete_screen_scheme id: 123
    end
  end

  it 'deletes a workflow' do
    output = "Workflow 'Software Simplified Workflow for Project MYPROJ' deleted."
    expect_cli_request("jira --action \"deleteWorkflow\" --workflow \"Software Simplified Workflow for Project MYPROJ\"", output, output) do
      @jira.delete_workflow name: 'Software Simplified Workflow for Project MYPROJ'
    end
  end

  it 'deletes a workflow scheme' do
    output = "Workflow scheme 123 deleted."
    expect_cli_request("jira --action \"deleteWorkflowScheme\" --id \"123\"", output, output) do
      @jira.delete_workflow_scheme id: 123
    end
  end

  it 'gets server info' do
    output = "JIRA version: 7.3.0, build: 73011, time: 1/3/17 12:00 AM, time zone: Central Standard Time, description: My Description, url: http://jira.<my_domain>.com"
    expect_cli_request("jira --action \"getServerInfo\"", output, output) do
      @jira.get_server_info
    end
  end

  it 'gets issue type screen scheme list' do
    cli_response = '5 issue type screen schemes in list
"Id","Name","Description","Delete Enabled","Projects"
"11100","ADF: Scrum Issue Type Screen Scheme","","No","SSO,ADF,FMAP"
"11201","BIT: Scrum Issue Type Screen Scheme","","No","BIT"
"10905","BPCU: Software Development Issue Type Screen Scheme","","No","BPCU"
"10908","Change Request","","No","OCM"
"10300","Client Support","","No","TAS"'

    expected_result = {
      11100 => {
                    :name => "ADF: Scrum Issue Type Screen Scheme",
          :delete_enabled => "No",
                :projects => "SSO,ADF,FMAP"
      },
      11201 => {
                    :name => "BIT: Scrum Issue Type Screen Scheme",
          :delete_enabled => "No",
                :projects => "BIT"
      },
      10905 => {
                    :name => "BPCU: Software Development Issue Type Screen Scheme",
          :delete_enabled => "No",
                :projects => "BPCU"
      },
      10908 => {
                    :name => "Change Request",
          :delete_enabled => "No",
                :projects => "OCM"
      },
      10300 => {
                    :name => "Client Support",
          :delete_enabled => "No",
                :projects => "TAS"
      }
    }
    expect_cli_request("jira --action \"getIssueTypeScreenSchemeList\"", cli_response, expected_result) do
      @jira.get_issue_type_screen_scheme_list
    end
  end

  it 'gets issue type scheme list' do
    cli_response = '4 issue type schemes in list
"Id","Name","Description","Delete Enabled","Issue Types","Projects"
"10000","Default Issue Type Scheme","Default issue type scheme is the list of global issue types. All newly created issue types will automatically be added to this scheme.","No","Bug,New Feature,Task,Improvement,Sub-task,Epic,Story,Spike",""
"10100","Agile Scrum Issue Type Scheme","This issue type scheme is used by GreenHoppers Scrum project template. Projects associated with the Scrum template will be associated to this scheme. You can modify this scheme.","Yes","Epic,Story,Technical task,Bug,Improvement,Uncategorized","CEE,HRE,INFRAPR,OSI"
"10200","IT Tech Support","","Yes","General Support,Hardware Issue,Select University,Select Education,Virus/Malware,Software Install,Email,Mobile Device,Printer,Hardware Request,Replacement","ITS"
"10300","Facility Setup Issue Type Scheme","","Yes","New Facility,Contract Maintenance,NF - Request Office Supplies,NF - Hardware Setup,NF - Data Setup,NF - Request Start Up Kits,NF - Request Telecomm,NF - EMR Setup,NF - Request Payroll","NFSP,FMD"'

    expected_result = {
      10000 => {
                    :name => "Default Issue Type Scheme",
             :description => "Default issue type scheme is the list of global issue types. All newly created issue types will automatically be added to this scheme.",
          :delete_enabled => "No",
             :issue_types => "Bug,New Feature,Task,Improvement,Sub-task,Epic,Story,Spike"
      },
      10100 => {
                    :name => "Agile Scrum Issue Type Scheme",
             :description => "This issue type scheme is used by GreenHoppers Scrum project template. Projects associated with the Scrum template will be associated to this scheme. You can modify this scheme.",
          :delete_enabled => "Yes",
             :issue_types => "Epic,Story,Technical task,Bug,Improvement,Uncategorized",
                :projects => "CEE,HRE,INFRAPR,OSI"
      },
      10200 => {
                    :name => "IT Tech Support",
          :delete_enabled => "Yes",
             :issue_types => "General Support,Hardware Issue,Select University,Select Education,Virus/Malware,Software Install,Email,Mobile Device,Printer,Hardware Request,Replacement",
                :projects => "ITS"
      },
      10300 => {
                    :name => "Facility Setup Issue Type Scheme",
          :delete_enabled => "Yes",
             :issue_types => "New Facility,Contract Maintenance,NF - Request Office Supplies,NF - Hardware Setup,NF - Data Setup,NF - Request Start Up Kits,NF - Request Telecomm,NF - EMR Setup,NF - Request Payroll",
                :projects => "NFSP,FMD"
      }
    }
    expect_cli_request("jira --action \"getIssueTypeSchemeList\"", cli_response, expected_result) do
      @jira.get_issue_type_scheme_list
    end
  end

  it 'gets screen list' do
    cli_response = '9 screens in list
"Id","Name","Description","Delete Enabled","Screen Schemes","Workflows"
"11601","ADF: Scrum Bug Screen","","No","ADF: Scrum Bug Screen Scheme",""
"11600","ADF: Scrum Default Issue Screen","","No","ADF: Scrum Default Screen Scheme,Default Screen Scheme",""
"10101","Add Technology","","Yes","",""
"11703","BIT: Scrum Bug Screen","","No","BIT: Scrum Bug Screen Scheme",""
"11702","BIT: Scrum Default Issue Screen","","No","BIT: Scrum Default Screen Scheme",""
"11416","BPCU: Software Development Bug Screen","","No","BPCU: Software Development Bug Screen Scheme",""
"11415","BPCU: Software Development Default Issue Screen","","No","BPCU: Software Development Default Screen Scheme",""
"11417","BPCU: Software Development Resolve Issue Screen","","No","","BPCU: Software Development Workflow,BPCU: Software Development Workflow,BPCU: Software Development Workflow"
"11422","Change Request Screen","","No","Change Request Scheme",""'

    expected_result = {
      11601 => {
                    :name => "ADF: Scrum Bug Screen",
          :delete_enabled => "No",
          :screen_schemes => "ADF: Scrum Bug Screen Scheme"
      },
      11600 => {
                    :name => "ADF: Scrum Default Issue Screen",
          :delete_enabled => "No",
          :screen_schemes => "ADF: Scrum Default Screen Scheme,Default Screen Scheme"
      },
      10101 => {
                    :name => "Add Technology",
          :delete_enabled => "Yes"
      },
      11703 => {
                    :name => "BIT: Scrum Bug Screen",
          :delete_enabled => "No",
          :screen_schemes => "BIT: Scrum Bug Screen Scheme"
      },
      11702 => {
                    :name => "BIT: Scrum Default Issue Screen",
          :delete_enabled => "No",
          :screen_schemes => "BIT: Scrum Default Screen Scheme"
      },
      11416 => {
                    :name => "BPCU: Software Development Bug Screen",
          :delete_enabled => "No",
          :screen_schemes => "BPCU: Software Development Bug Screen Scheme"
      },
      11415 => {
                    :name => "BPCU: Software Development Default Issue Screen",
          :delete_enabled => "No",
          :screen_schemes => "BPCU: Software Development Default Screen Scheme"
      },
      11417 => {
                    :name => "BPCU: Software Development Resolve Issue Screen",
          :delete_enabled => "No",
               :workflows => "BPCU: Software Development Workflow,BPCU: Software Development Workflow,BPCU: Software Development Workflow"
      },
      11422 => {
                    :name => "Change Request Screen",
          :delete_enabled => "No",
          :screen_schemes => "Change Request Scheme"
      }
    }
    expect_cli_request("jira --action \"getScreenList\"", cli_response, expected_result) do
      @jira.get_screen_list
    end
  end

  it 'gets screen scheme list' do
    cli_response = '8 screen schemes in list
"Id","Name","Description","Delete Enabled","Issue Type Screen Schemes"
"11401","ADF: Scrum Bug Screen Scheme","","No","ADF: Scrum Issue Type Screen Scheme"
"11400","ADF: Scrum Default Screen Scheme","","No","ADF: Scrum Issue Type Screen Scheme"
"11503","BIT: Scrum Bug Screen Scheme","","No","BIT: Scrum Issue Type Screen Scheme"
"11502","BIT: Scrum Default Screen Scheme","","No","BIT: Scrum Issue Type Screen Scheme"
"11209","BPCU: Software Development Bug Screen Scheme","","No","BPCU: Software Development Issue Type Screen Scheme"
"11208","BPCU: Software Development Default Screen Scheme","","No","BPCU: Software Development Issue Type Screen Scheme"
"11212","Change Request Scheme","","No","Change Request"
"10701","Contract Maintenance","","No","New Facility Screen Scheme"'

    expected_result = {
      11401 => {
                               :name => "ADF: Scrum Bug Screen Scheme",
                     :delete_enabled => "No",
          :issue_type_screen_schemes => "ADF: Scrum Issue Type Screen Scheme"
      },
      11400 => {
                               :name => "ADF: Scrum Default Screen Scheme",
                     :delete_enabled => "No",
          :issue_type_screen_schemes => "ADF: Scrum Issue Type Screen Scheme"
      },
      11503 => {
                               :name => "BIT: Scrum Bug Screen Scheme",
                     :delete_enabled => "No",
          :issue_type_screen_schemes => "BIT: Scrum Issue Type Screen Scheme"
      },
      11502 => {
                               :name => "BIT: Scrum Default Screen Scheme",
                     :delete_enabled => "No",
          :issue_type_screen_schemes => "BIT: Scrum Issue Type Screen Scheme"
      },
      11209 => {
                               :name => "BPCU: Software Development Bug Screen Scheme",
                     :delete_enabled => "No",
          :issue_type_screen_schemes => "BPCU: Software Development Issue Type Screen Scheme"
      },
      11208 => {
                               :name => "BPCU: Software Development Default Screen Scheme",
                     :delete_enabled => "No",
          :issue_type_screen_schemes => "BPCU: Software Development Issue Type Screen Scheme"
      },
      11212 => {
                               :name => "Change Request Scheme",
                     :delete_enabled => "No",
          :issue_type_screen_schemes => "Change Request"
      },
      10701 => {
                               :name => "Contract Maintenance",
                     :delete_enabled => "No",
          :issue_type_screen_schemes => "New Facility Screen Scheme"
      }
    }
    expect_cli_request("jira --action \"getScreenSchemeList\"", cli_response, expected_result) do
      @jira.get_screen_scheme_list
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
    expect_cli_request("jira --action \"getWorkflowList\"", cli_response, expected_result) do
      @jira.get_workflow_list
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
    expect_cli_request("jira --action \"getWorkflowSchemeList\"", cli_response, expected_result) do
      @jira.get_workflow_scheme_list
    end
  end
end
