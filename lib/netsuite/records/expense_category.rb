module NetSuite
  module Records
    class ExpenseCategory
      include Support::Fields
      include Support::Actions
      include Namespaces::ListAcct

      actions :search

      fields :name

      attr_reader :internal_id

      def initialize(attributes = {})
        @internal_id = attributes.delete(:internal_id) || attributes.delete(:@internal_id)
        initialize_from_attributes_hash(attributes)
      end
    end
  end
end
