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
end
