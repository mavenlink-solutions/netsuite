module NetSuite
  module Records
    class MessageMediaItemList
      include Support::Fields
      include Support::RecordRefs
      include Support::Records
      include Namespaces::CommGeneral

      fields :media_item

      attr_accessor :replace_all

      def initialize(attributes = {})
        @replace_all = attributes.delete(:replace_all) || attributes.delete(:replace_all)
        initialize_from_attributes_hash(attributes)
      end
    end
  end
end
