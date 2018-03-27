module NetSuite
  module Records
    class Message
      include Support::Records
      include Support::Fields

      include Support::Actions
      include Support::RecordRefs
      include Namespaces::CommGeneral

      # https://system.netsuite.com/help/helpcenter/en_US/srbrowser/Browser2016_2/schema/record/message.html

      actions :get, :get_list, :add, :update, :upsert, :upsert_list, :delete, :delete_list, :search

      fields :authorEmail, :bcc, :cc, :compressAttachments, :dateTime, :emailed, :incoming, :lastModifiedDate, :message,
             :messageDate, :recipientEmail, :recordName, :recordTypeName, :subject

      record_refs :activity, :author, :recipient, :transaction

      field :media_item_list, MessageMediaItemList

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
