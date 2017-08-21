module JiraCli
  class Wrapper
    include Singleton

    def initialize
      [
        :add_attachment,
        :add_comment,
        :create_issue,
        :create_project,
        :delete_issue,
        :delete_issue_type_scheme,
        :delete_issue_type_screen_scheme,
        :delete_project,
        :delete_screen,
        :delete_screen_scheme,
        :delete_version,
        :delete_workflow,
        :delete_workflow_scheme,
        :get_server_info,
        :release_version,
        :remove_attachment,
        :remove_comment,
        :transition_issue
      ].each do |s_method|
        define_singleton_method s_method, -> **jira_args {jira_cmd s_method.to_s.camelize(:lower), **jira_args}
      end

      {
        get_attachment_list:               {label: 'attachments',               id_col: :id},
        get_comment_list:                  {label: 'comments',                  id_col: :id},
        get_issue_list:                    {label: 'issues',                    id_col: :id},
        get_issue_type_screen_scheme_list: {label: 'issue type screen schemes', id_col: :id},
        get_issue_type_scheme_list:        {label: 'issue type schemes',        id_col: :id},
        get_screen_list:                   {label: 'screens',                   id_col: :id},
        get_screen_scheme_list:            {label: 'screen schemes',            id_col: :id},
        get_version_list:                  {label: 'versions',                  id_col: :id},
        get_workflow_list:                 {label: 'workflows',                 id_col: :name},
        get_workflow_scheme_list:          {label: 'workflow schemes',          id_col: :id}
      }.each do |s_method, csv_args|
        define_singleton_method s_method, -> **jira_args {get_csv_list **{cmd: s_method.to_s.camelize(:lower)}.merge(**jira_args, **csv_args)}
      end
    end

    def add_version project:, name:, **jira_args
      formatted_args = jira_args.map do |k, v|
        v = v.strftime('%-m/%d/%y') if [:start_date, :date].include?(k)
        [k, v]
      end.to_h
      jira_cmd 'addVersion', project: project, name: name, **formatted_args
    end

    private

    def check_first_line output, regex
      raise OutputError.new("Expected response to begin with \"#{regex}\"", output) unless output =~ Regexp.new(regex)
    end

    def get_csv_list cmd:, label:, id_col:, **jira_args
      output = jira_cmd cmd, **jira_args
      check_first_line output, '^\d* '+label
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
            [k.gsub(/\s/,'').underscore.to_sym, v =~ /\A\d+\z/ ? v.to_i : v]
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
