module JiraCli
  class Wrapper
    include Singleton

    CLI_METHODS = [:add_attachment, :add_attachments, :add_comment, :add_component, :add_custom_field, :add_group, :add_labels, :add_project_category, :add_project_role, :add_project_role_actors, :add_remote_link, :add_transition, :add_transition_function, :add_user, :add_user_to_group, :add_user_to_group_with_file, :add_user_with_file, :add_version, :add_vote, :add_watchers, :add_work, :archive_version, :assign_issue, :associate_workflow, :clone_issue, :clone_issues, :clone_project, :copy_attachments, :copy_component, :copy_components, :copy_field_value, :copy_project_role_actors, :copy_version, :copy_versions, :copy_workflow, :create_board, :create_filter, :create_issue, :create_or_update_issue, :create_project, :create_workflow_scheme, :delete_board, :delete_component, :delete_field_configuration, :delete_field_configuration_scheme, :delete_filter, :delete_issue, :delete_issue_security_scheme, :delete_issue_type_scheme, :delete_issue_type_screen_scheme, :delete_link, :delete_notification_scheme, :delete_permission_scheme, :delete_project, :delete_screen, :delete_screen_scheme, :delete_version, :delete_workflow, :delete_workflow_scheme, :export_data, :export_site, :export_workflow, :get_application_link_list, :get_attachment, :get_attachment_list, :get_available_steps, :get_board_list, :get_client_info, :get_comment, :get_comment_list, :get_comments, :get_component, :get_component_list, :get_custom_field_list, :get_field_configuration_list, :get_field_configuration_scheme_list, :get_field_list, :get_field_value, :get_filter, :get_filter_list, :get_group_list, :get_issue, :get_issue_history_list, :get_issue_list, :get_issue_security_scheme_list, :get_issue_type_list, :get_issue_type_scheme_list, :get_issue_type_screen_scheme_list, :get_link_list, :get_link_type_list, :get_login_info, :get_notification_scheme_list, :get_permission_scheme_list, :get_project, :get_project_category, :get_project_category_list, :get_project_list, :get_project_role_actor_list, :get_project_role_by_user_list, :get_project_role_list, :get_remote_link_list, :get_screen_list, :get_screen_scheme_list, :get_security_level_list, :get_server_info, :get_status_list, :get_transition_list, :get_user, :get_user_list, :get_version, :get_version_list, :get_voter_list, :get_watcher_list, :get_workflow, :get_workflow_list, :get_workflow_scheme, :get_workflow_scheme_list, :get_work_list, :import, :import_workflow, :link_issue, :login, :logout, :modify_field_value, :progress_issue, :release_version, :remove_attachment, :remove_comment, :remove_custom_field, :remove_group, :remove_labels, :remove_project_category, :remove_project_role, :remove_project_role_actors, :remove_remote_link, :remove_user, :remove_user_from_group, :remove_user_from_group_with_file, :remove_user_property, :remove_user_with_file, :remove_vote, :remove_watchers, :remove_work, :render_request, :restore_export, :run, :run_from_attachment_list, :run_from_comment_list, :run_from_component_list, :run_from_csv, :run_from_field_configuration_list, :run_from_field_configuration_scheme_list, :run_from_group_list, :run_from_issue_list, :run_from_issue_security_scheme_list, :run_from_issue_type_scheme_list, :run_from_issue_type_screen_scheme_list, :run_from_link_list, :run_from_list, :run_from_notification_scheme_list, :run_from_permission_scheme_list, :run_from_project_category_list, :run_from_project_list, :run_from_remote_link_list, :run_from_screen_list, :run_from_screen_scheme_list, :run_from_sql, :run_from_user_list, :run_from_version_list, :run_from_workflow_list, :run_from_workflow_scheme_list, :set_field_value, :set_share_scope, :transition_issue, :unarchive_version, :unrelease_version, :update_comment, :update_component, :update_filter, :update_issue, :update_project, :update_project_category, :update_project_role, :update_user, :update_user_property, :update_version, :update_work, :validate_license]

    CSV_RESPONSE_METHODS = {
      get_attachment_list:               {label: 'attachments',               id_col: :id},
      get_comment_list:                  {label: 'comments',                  id_col: :id},
      get_component_list:                {label: 'components',                id_col: :id},
      get_issue_list:                    {label: 'issues',                    id_col: :id},
      get_issue_type_list:               {label: 'issue types',               id_col: :id},
      get_issue_type_screen_scheme_list: {label: 'issue type screen schemes', id_col: :id},
      get_issue_type_scheme_list:        {label: 'issue type schemes',        id_col: :id},
      get_link_list:                     {label: 'links',                     id_col: :link_id},
      get_screen_list:                   {label: 'screens',                   id_col: :id},
      get_screen_scheme_list:            {label: 'screen schemes',            id_col: :id},
      get_version_list:                  {label: 'versions',                  id_col: :id},
      get_workflow_list:                 {label: 'workflows',                 id_col: :name},
      get_workflow_scheme_list:          {label: 'workflow schemes',          id_col: :id}
    }

    def initialize
      @jira_cmd = configure_jira_cmd
      define_cli_methods
    end

    private

    def check_first_line output, regex
      raise OutputError.new("Expected response to begin with \"#{regex}\"", output) unless output =~ Regexp.new(regex)
    end

    def configure_jira_cmd
      cli_opts = {
        server:   :server_url,
        user:     :user,
        password: :password
      }.map do |cli_opt, config_var|
        JiraCli.send(config_var) ? "--#{cli_opt} \"#{JiraCli.send(config_var)}\"" : nil
      end.compact

      [JiraCli.cli_jar_path ? "java -jar \"#{JiraCli.cli_jar_path}\"" : 'jira', *cli_opts].join ' '
    end

    def define_cli_methods
      CLI_METHODS.each do |s_method|
        cli_method = s_method.to_s.camelize(:lower)

        define_singleton_method s_method, -> **jira_args do
          if jira_args.delete(:parse_response) && CSV_RESPONSE_METHODS[s_method]
            get_csv_list **{cmd: cli_method}.merge(**jira_args, **CSV_RESPONSE_METHODS[s_method])
          else
            jira_cmd cli_method, **jira_args
          end
        end
      end
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
      cmd_args = {action: action}.merge(jira_args).map do |k,v|
        cmd = "--#{k.to_s.camelize(:lower)}"
        unless v.is_a? TrueClass
          cmd += v.to_s.include?('"') && !v.to_s.include?('""') ? " '#{v}'" : " \"#{v}\""
        end
        cmd
      end.join(' ')

      stdout, stderr, status = Open3.capture3 "#{@jira_cmd} #{cmd_args}"

      # ap "jira #{cmd_args}"
      # puts stdout
      raise stderr.strip if stderr != ''
      stdout.strip
    end
  end
end
