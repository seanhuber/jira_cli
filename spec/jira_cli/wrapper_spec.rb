RSpec.describe JiraCli::Wrapper do
  it 'gets server info' do
    stdout = "JIRA version: 7.3.0, build: 73011, time: 1/3/17 12:00 AM, time zone: Central Standard Time, description: My Description, url: http://jira.<my_domain>.com"
    stderr = ''
    status = ''
    expect(Open3).to receive(:capture3).with("jira --action \"getServerInfo\"").and_return([stdout, stderr, status])

    jira = JiraCli::Wrapper.new
    server_info = jira.get_server_info
    expect(server_info).to eq(stdout)
  end

  it 'gets workflow list' do
    stdout = '5 workflows in list
"Name","Description","Last Modified","Last Modifier","Step Count","Default"
"jira","The default JIRA workflow.","","","5","Yes"
"PROJ1: Software Development Workflow","","02/27/2015 11:16 AM","Jane Doe","4","No"
"PROJ2: Software Development Workflow","","02/27/2015 11:26 AM","Jane Doe","4","No"
"PROJ3: Software Development Workflow","","02/27/2015 11:19 AM","Jane Doe","4","No"
"PROJ4: Software Development Workflow","","02/27/2015 11:37 AM","Jane Doe","4","No"'
    stderr = ''
    status = ''
    expect(Open3).to receive(:capture3).with("jira --action \"getWorkflowList\"").and_return([stdout, stderr, status])

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
    workflow_list = jira.get_workflow_list
    expect(workflow_list).to eq(expected_result)
  end
end
