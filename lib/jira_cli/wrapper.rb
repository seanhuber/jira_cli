module JiraCli
  class Wrapper
    def create_project key:, lead:
      jira_cmd 'createProject', project: key, lead: lead
    end

    def delete_issue_type_scheme id:
      jira_cmd 'deleteIssueTypeScheme', id: id
    end

    def delete_issue_type_screen_scheme id:
      jira_cmd 'deleteIssueTypeScreenScheme', id: id
    end

    def delete_project key:
      jira_cmd 'deleteProject', project: key
    end

    def delete_screen id:
      jira_cmd 'deleteScreen', id: id
    end

    def delete_screen_scheme id:
      jira_cmd 'deleteScreenScheme', id: id
    end

    def delete_workflow name:
      jira_cmd 'deleteWorkflow', workflow: name
    end

    def delete_workflow_scheme id:
      jira_cmd 'deleteWorkflowScheme', id: id
    end

    def get_server_info
      jira_cmd 'getServerInfo'
    end

    def get_issue_type_screen_scheme_list **jira_args
      get_csv_list cmd: 'getIssueTypeScreenSchemeList', resource_name: 'issue type screen schemes', **jira_args
    end

    def get_issue_type_scheme_list **jira_args
      get_csv_list cmd: 'getIssueTypeSchemeList', resource_name: 'issue type schemes', **jira_args
    end

    def get_screen_list **jira_args
      get_csv_list cmd: 'getScreenList', resource_name: 'screens', **jira_args
    end

    def get_screen_scheme_list **jira_args
      get_csv_list cmd: 'getScreenSchemeList', resource_name: 'screen schemes', **jira_args
    end

    def get_workflow_list **jira_args
      get_csv_list cmd: 'getWorkflowList', resource_name: 'workflows', id_col: :name, **jira_args
    end

    def get_workflow_scheme_list **jira_args
      get_csv_list cmd: 'getWorkflowSchemeList', resource_name: 'workflow schemes', **jira_args
    end

    private

    def check_first_line output, regex
      raise OutputError.new("Expected response to begin with \"#{regex}\"", output) unless output =~ Regexp.new(regex)
    end

    def get_csv_list cmd:, resource_name:, id_col: :id, **jira_args
      output = jira_cmd cmd, **jira_args
      check_first_line output, '^\d* '+resource_name+' in list'
      return {} unless output.index("\n")
      output = output[output.index("\n")+1..-1] # removing first line of output
      arr = parse_csv output
      arr.map{|h| [h[id_col], h.except(id_col)]}.to_h
    end

    def parse_csv str
      CSV.parse(str, headers: true).map do |row|
        row.map do |k,v|
          if v.blank?
            nil
          else
            key = k.gsub(/\s/,'').underscore.to_sym
            value = if v =~ /\A\d+\z/
              v.to_i
            else
              v
            end
            [key, value]
          end
        end.compact.to_h
      end
    end

    def jira_cmd action, **jira_args
      cmd_args = {action: action}.merge(jira_args).map{|k,v| "--#{k.to_s.camelize(:lower)} \"#{v}\""}.join(' ')
      stdout, stderr, status = Open3.capture3 "jira #{cmd_args}"
      # ap "jira #{cmd_args}"
      # puts stdout
      raise stderr.strip if stderr != ''
      stdout.strip
    end
  end
end
