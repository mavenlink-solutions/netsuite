module NetSuite
  module Records
    class ItemFulfillmentItemList < Support::Sublist
      include Namespaces::TranSales

      fields :replace_all

      sublist :item, ItemFulfillmentItem

      alias :items :item
    end
  end
end
