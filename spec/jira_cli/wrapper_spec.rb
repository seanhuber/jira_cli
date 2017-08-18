RSpec.describe JiraCli::Wrapper do
  before(:all) do
    @jira = JiraCli::Wrapper.new
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
