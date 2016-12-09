module NetSuite
  module Records
    class ExpenseCategory
      include Support::Fields
      include Support::Actions
      include Namespaces::ListAcct

      # https://system.netsuite.com/help/helpcenter/en_US/srbrowser/Browser2014_1/script/record/expensecategory.html

      actions :search

      fields :name

      attr_reader :internal_id

      def initialize(attributes = {})
        @internal_id = attributes.delete(:internal_id) || attributes.delete(:@internal_id)
        initialize_from_attributes_hash(attributes)
      end

      def self.search_class_name
        'ExpenseCategory'
      end
    end
  end
end
