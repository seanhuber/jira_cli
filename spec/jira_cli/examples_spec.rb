RSpec.describe JiraCli::Wrapper do
  before(:all) do
    @jira = JiraCli::Wrapper.instance
  end

  YAML.load_file('examples.yml')[0..-1].each do |example|
    it "Generates example: #{example[:cli_example]}" do
      expect(Open3).to receive(:capture3).with("jira #{example[:cli_example]}").and_return(['', '', ''])

      wpr_method = example[:gem_example][:action]
      
      @jira.send example[:gem_example][:action], example[:gem_example].except(:action)
    end
  end
end
