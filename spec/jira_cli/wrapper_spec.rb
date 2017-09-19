RSpec.describe JiraCli::Wrapper do
  context 'standard configuration' do
    before(:all) do
      @jira = JiraCli::Wrapper.instance
    end

    YAML.load_file('spec/cli_specs.yml').each do |wpr_method, args|
      it args[:desc] do
        expect(Open3).to receive(:capture3).with(args[:cmd]).and_return([args[:cmd_response], '', ''])

        arr = [wpr_method]
        arr << args[:gem_args] if args[:gem_args]
        gem_response = @jira.send *arr

        expect(gem_response).to eq(args[:gem_response])
      end
    end
  end

  context 'advanced configuration' do
    it 'can be configured with jar path, server url, username, and password' do
      JiraCli.setup do |config|
        config.cli_jar_path = '/path/to/jira-cli-6.7.0.jar'
        config.server_url   = 'http://jira.mywebsite.com'
        config.user         = 'my_username'
        config.password     = 'my_password'
      end

      jira = JiraCli::Wrapper.clone.instance

      expected_cmd = "java -jar \"/path/to/jira-cli-6.7.0.jar\" --server \"http://jira.mywebsite.com\" --user \"my_username\" --password \"my_password\" --action \"getServerInfo\""

      expected_response = "JIRA version: 7.3.0, build: 73011, time: 1/3/17 12:00 AM, time zone: Central Standard Time, description: Select Tasks, url: http://jira.mywebsite.com"

      expect(Open3).to receive(:capture3).with(expected_cmd).and_return([expected_response, '', ''])

      expect(jira.get_server_info).to eq(expected_response)

      JiraCli.setup do |config|
        config.cli_jar_path = nil
        config.server_url   = nil
        config.user         = nil
        config.password     = nil
      end
    end
  end
end
