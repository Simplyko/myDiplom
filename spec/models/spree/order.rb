require 'rails_helper'

RSpec.describe Spree::Order do
  it "generates an order and advances it to the address state" do
    order = FactoryBot.create(:order_with_line_items)
    order.next!
    expect(order.state).to eq("address")
  end
end