module NetSuite
  module Records
    class JobPercentCompleteOverrideList < Support::Sublist
      include Namespaces::ListRel

      sublist :job_percent_complete_override, JobPercentCompleteOverride

      alias :job_percent_complete_overrides :job_percent_complete_override
    end
  end
end
