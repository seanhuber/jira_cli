require 'bundler/setup'
require 'jira_cli'
require 'ap'
require 'yaml'

YAML.load_file('examples.yml')[0..-1].each do |example|
  # ap example
  cmd = "jira.#{example[:gem_example][:action]}"
  "#{example[:gem_example].except(:action)}"
  cmd_args = example[:gem_example].except(:action).map do |k,v|
    "#{k}: #{v.inspect}"
  end
  cmd += "(#{cmd_args.join(', ')})" if cmd_args.any?
  # puts "\njira #{example[:cli_example]}"
  # puts cmd
  puts "|`jira #{example[:cli_example]}`|`#{cmd}`|"
end

# |`asdf`|```puts 'test'```|
