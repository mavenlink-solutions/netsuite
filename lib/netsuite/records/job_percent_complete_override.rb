module NetSuite
  module Records
    class JobPercentCompleteOverride
      include Support::Fields
      include Support::Records
      include Namespaces::ListRel

      fields :comments, :percent

      field :period, AccountingPeriod

      def initialize(attributes = {})
        initialize_from_attributes_hash(attributes)
      end
    end
  end
end
