module JiraCli
  class Wrapper
    def get_server_info
      jira_cmd 'getServerInfo'
    end

    def get_issue_type_scheme_list
      get_csv_list cmd: 'getIssueTypeSchemeList', resource_name: 'issue type schemes'
    end

    def get_workflow_list
      get_csv_list cmd: 'getWorkflowList', resource_name: 'workflows', id_col: :name
    end

    def get_workflow_scheme_list
      get_csv_list cmd: 'getWorkflowSchemeList', resource_name: 'workflow schemes'
    end

    private

    def check_first_line output, regex
      raise OutputError.new("Expected response to begin with \"#{regex}\"", output) unless output =~ Regexp.new(regex)
    end

    def get_csv_list cmd:, resource_name:, id_col: :id
      output = jira_cmd cmd
      check_first_line output, '^\d* '+resource_name+' in list'
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

    def jira_cmd action
      stdout, stderr, status = Open3.capture3 "jira --action #{action}"
      raise stderr.strip if stderr != ''
      stdout.strip
    end
  end
end
