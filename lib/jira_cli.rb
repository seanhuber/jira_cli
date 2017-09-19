require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'

require 'csv'
require 'open3'

require 'jira_cli/version'
require 'jira_cli/wrapper'
require 'jira_cli/output_error'

module JiraCli
  mattr_accessor :cli_jar_path
  @@cli_jar_path = nil

  mattr_accessor :password
  @@password = nil

  mattr_accessor :server_url
  @@server_url = nil

  mattr_accessor :user
  @@user = nil

  def self.setup
    yield self
  end
end
