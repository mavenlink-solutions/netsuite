module NetSuite
  module Records
    class ResourceAllocation
      include Support::Fields
      include Support::RecordRefs
      include Support::Records
      include Support::Actions
      include Namespaces::ActSched

      actions :get, :get_list, :add, :search, :delete, :update, :upsert

      fields :allocation_amount, :end_date, :notes, :number_hours, :percent_of_time, :start_date, :allocation_unit, :approval_status

      field :custom_field_list, CustomFieldList

      record_refs :allocation_resource, :allocation_type, :custom_form, :next_approver, :project, :request_by

      attr_reader   :internal_id
      attr_accessor :external_id

      def initialize(attributes = {})
        @internal_id = attributes.delete(:internal_id) || attributes.delete(:@internal_id)
        @external_id = attributes.delete(:external_id) || attributes.delete(:@external_id)
        initialize_from_attributes_hash(attributes)
      end
    end
  end
end
