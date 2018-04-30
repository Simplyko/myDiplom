require 'rails_helper'

class FakeCalculator < Spree::Calculator
  def compute(_computable)
    5
  end
end

RSpec.describe Spree::Order, type: :model do
  let(:user) { stub_model(Spree::LegacyUser) }
  let(:order) { stub_model(Spree::Order) }

  before do
    create(:store)
    allow(Spree::LegacyUser).to receive_messages(current: mock_model(Spree::LegacyUser, id: 123))
  end

  describe '.scopes' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:completed_order) { FactoryBot.create(:order, user: user, completed_at: Time.current) }
    let!(:incompleted_order) { FactoryBot.create(:order, user: user, completed_at: nil) }

    describe '.complete' do
      it { expect(Spree::Order.complete).to include completed_order }
      it { expect(Spree::Order.complete).not_to include incompleted_order }
    end

    describe '.incomplete' do
      it { expect(Spree::Order.incomplete).to include incompleted_order }
      it { expect(Spree::Order.incomplete).not_to include completed_order }
    end
  end

  describe '#update_with_updater!' do
    let(:updater) { Spree::OrderUpdater.new(order) }

    before do
      allow(order).to receive(:updater).and_return(updater)
      allow(updater).to receive(:update).and_return(true)
    end

    after { order.update_with_updater! }

    it 'expects to update order with order updater' do
      expect(updater).to receive(:update).and_return(true)
    end
  end

  context '#cancel' do
    let(:order) { create(:completed_order_with_totals) }
    let!(:payment) do
      create(
        :payment,
        order: order,
        amount: order.total,
        state: 'completed'
      )
    end
    let(:payment_method) { double }

    it 'marks the payments as void' do
      allow_any_instance_of(Spree::Shipment).to receive(:refresh_rates).and_return(true)
      order.cancel
      order.reload

      expect(order.payments.first).to be_void
    end
  end

  context '#canceled_by' do
    subject { order.canceled_by(admin_user) }

    let(:admin_user) { create :admin_user }
    let(:order) { create :order }

    before do
      allow(order).to receive(:cancel!)
    end

    it 'cancels the order' do
      expect(order).to receive(:cancel!)
      subject
    end

    it 'saves canceler_id' do
      subject
      expect(order.reload.canceler_id).to eq(admin_user.id)
    end

    it 'saves canceled_at' do
      subject
      expect(order.reload.canceled_at).not_to be_nil
    end

    it 'has canceler' do
      subject
      expect(order.reload.canceler).to eq(admin_user)
    end
  end

  context '#create' do
    let(:order) { Spree::Order.create }

    it 'assigns an order number' do
      expect(order.number).not_to be_nil
    end

    it 'creates a randomized 35 character token' do
      expect(order.guest_token.size).to eq(35)
    end
  end

  context 'creates shipments cost' do
    let(:shipment) { double }

    before { allow(order).to receive_messages shipments: [shipment] }

    it 'update and persist totals' do
      expect(shipment).to receive :update_amounts
      expect(order.updater).to receive :update_shipment_total
      expect(order.updater).to receive :persist_totals

      order.set_shipments_cost
    end
  end

  context '#finalize!' do
    let(:order) { Spree::Order.create(email: 'test@example.com') }

    before do
      order.update_column :state, 'complete'
    end

    it 'sets completed_at' do
      expect(order).to receive(:touch).with(:completed_at)
      order.finalize!
    end

    it 'sells inventory units' do
      order.shipments.each do |shipment| # rubocop:disable RSpec/IteratedExpectation
        expect(shipment).to receive(:update!)
        expect(shipment).to receive(:finalize!)
      end
      order.finalize!
    end

    it 'decreases the stock for each variant in the shipment' do
      order.shipments.each do |shipment|
        expect(shipment.stock_location).to receive(:decrease_stock_for_variant)
      end
      order.finalize!
    end
  end

  context 'empty!' do
    let(:order) { Spree::Order.create(email: 'test@example.com') }
    let(:promotion) { create :promotion, code: '10off' }

    before do
      promotion.orders << order
    end

    context 'completed order' do
      before do
        order.update_columns(state: 'complete', completed_at: Time.current)
      end

      it 'raises an exception' do
        expect { order.empty! }.to raise_error(RuntimeError, Spree.t(:cannot_empty_completed_order))
      end
    end

    context 'incomplete order' do
      before do
        order.empty!
      end

      it 'clears out line items, adjustments and update totals' do
        expect(order.line_items.count).to be_zero
        expect(order.adjustments.count).to be_zero
        expect(order.shipments.count).to be_zero
        expect(order.order_promotions.count).to be_zero
        expect(order.promo_total).to be_zero
        expect(order.item_total).to be_zero
        expect(order.empty!).to eq(order)
      end
    end
  end
 
  context '#confirmation_required?' do

    it "is required if the state is currently 'confirm'" do
      order = Spree::Order.new
      assert order.confirmation_required?
      order.state = 'confirm'
      assert order.confirmation_required?
    end

    context 'Spree::Config[:always_include_confirm_step] == true' do
      before do
        Spree::Config[:always_include_confirm_step] = true
      end

      it 'returns true if payments empty' do
        order = Spree::Order.new
        assert order.confirmation_required?
      end
    end

    context 'Spree::Config[:always_include_confirm_step] == false' do
      it 'returns false if payments empty and Spree::Config[:always_include_confirm_step] == false' do
        order = Spree::Order.new
        assert order.confirmation_required?
      end

      it 'does not bomb out when an order has an unpersisted payment' do
        order = Spree::Order.new
        order.payments.build
        assert order.confirmation_required?
      end
    end
  end

  describe '#restart_checkout_flow' do
    it 'updates the state column to the first checkout_steps value' do
      order = create(:order_with_totals, state: 'delivery')
      expect(order.checkout_steps).to eql ['address', 'delivery', 'complete']
      expect { order.restart_checkout_flow }.to change { order.state }.from('delivery').to('address')
    end

    context 'without line items' do
      it 'updates the state column to cart' do
        order = create(:order, state: 'delivery')
        expect { order.restart_checkout_flow }.to change { order.state }.from('delivery').to('cart')
      end
    end
  end

  context '#products' do
    before do
      @variant1 = mock_model(Spree::Variant, product: 'product1')
      @variant2 = mock_model(Spree::Variant, product: 'product2')
      @line_items = [mock_model(Spree::LineItem, product: 'product1', variant: @variant1, variant_id: @variant1.id, quantity: 1),
                     mock_model(Spree::LineItem, product: 'product2', variant: @variant2, variant_id: @variant2.id, quantity: 2)]
      allow(order).to receive_messages(line_items: @line_items)
    end

    it 'gets the quantity of a given variant' do
      expect(order.quantity_of(@variant1)).to eq(1)

      @variant3 = mock_model(Spree::Variant, product: 'product3')
      expect(order.quantity_of(@variant3)).to eq(0)
    end

    it 'can find a line item matching a given variant' do
      expect(order.find_line_item_by_variant(@variant1)).not_to be_nil
      expect(order.find_line_item_by_variant(mock_model(Spree::Variant))).to be_nil
    end

    context 'match line item with options' do
      before do
        Spree::Order.register_line_item_comparison_hook(:foos_match)
      end

      after do
        # reset to avoid test pollution
        Spree::Order.line_item_comparison_hooks = Set.new
      end

      it 'matches line item when options match' do
        allow(order).to receive(:foos_match).and_return(true)
        expect(order.line_item_options_match(@line_items.first, foos: { bar: :zoo })).to be true
      end

      it 'does not match line item without options' do
        allow(order).to receive(:foos_match).and_return(false)
        expect(order.line_item_options_match(@line_items.first, {})).to be false
      end
    end
  end

  describe '#associate_user!' do
    let(:user) { FactoryBot.create(:user_with_addreses) }
    let(:email) { user.email }
    let(:created_by) { user }
    let(:bill_address) { user.bill_address }
    let(:ship_address) { user.ship_address }
    let(:override_email) { true }

    let(:order) { FactoryBot.build(:order, order_attributes) }

    let(:order_attributes) do
      {
        user:         nil,
        email:        nil,
        created_by:   nil,
        bill_address: nil,
        ship_address: nil
      }
    end

    def assert_expected_order_state
      expect(order.user).to eql(user)
      expect(order.user_id).to eql(user.id)

      expect(order.email).to eql(email)

      expect(order.created_by).to eql(created_by)
      expect(order.created_by_id).to eql(created_by.id)

      expect(order.bill_address.same_as?(bill_address)).to be(true) if order.bill_address

      expect(order.ship_address.same_as?(ship_address)).to be(true) if order.ship_address
    end

    shared_examples_for '#associate_user!' do |persisted = false|
      it 'associates a user to an order' do
        order.associate_user!(user, override_email)
        assert_expected_order_state
      end

      unless persisted
        it 'does not persist the order' do
          expect { order.associate_user!(user) }.
            not_to change(order, :persisted?).
            from(false)
        end
      end
    end

    context 'when email is set' do
      let(:order_attributes) { super().merge(email: 'test@example.com') }

      context 'when email should be overridden' do
        it_behaves_like '#associate_user!'
      end

      context 'when email should not be overridden' do
        let(:override_email) { false }
        let(:email) { 'test@example.com' }

        it_behaves_like '#associate_user!'
      end
    end

    context 'when created_by is set' do
      let(:order_attributes) { super().merge(created_by: created_by) }
      let(:created_by) { create(:user_with_addreses) }

      it_behaves_like '#associate_user!'
    end

    context 'when bill_address is set' do
      let(:order_attributes) { super().merge(bill_address: bill_address) }
      let(:bill_address) { FactoryBot.build(:address) }

      it_behaves_like '#associate_user!'
    end

    context 'when ship_address is set' do
      let(:order_attributes) { super().merge(ship_address: ship_address) }
      let(:ship_address) { FactoryBot.build(:address) }

      it_behaves_like '#associate_user!'
    end

    context 'when the user is not persisted' do
      let(:user) { FactoryBot.build(:user_with_addreses) }

      it 'does not persist the user' do
        expect { order.associate_user!(user) }.
          not_to change(user, :persisted?).
          from(false)
      end

      it_behaves_like '#associate_user!'
    end

    context 'when the order is persisted' do
      let(:order) { FactoryBot.create(:order, order_attributes) }

      it 'associates a user to a persisted order' do
        order.associate_user!(user)
        order.reload
        assert_expected_order_state
      end

      it 'does not persist other changes to the order' do
        order.state = 'complete'
        order.associate_user!(user)
        order.reload
        expect(order.state).to eql('cart')
      end

      it 'does not change any other orders' do
        other = FactoryBot.create(:order)
        order.associate_user!(user)
        expect(other.reload.user).not_to eql(user)
      end

      it 'is not affected by scoping' do
        order.class.where.not(id: order).scoping do
          order.associate_user!(user)
        end
        order.reload
        assert_expected_order_state
      end

      it_behaves_like '#associate_user!', true
    end
  end

  context '#completed?' do
    it 'indicates if order is completed' do
      order.completed_at = nil
      expect(order.completed?).to be false

      order.completed_at = Time.current
      expect(order.completed?).to be true
    end
  end

  context '#allow_checkout?' do
    it 'is true if there are line_items in the order' do
      allow(order).to receive_message_chain(:line_items, :exists?).and_return(true)
      expect(order.checkout_allowed?).to be true
    end
    it 'is false if there are no line_items in the order' do
      allow(order).to receive_message_chain(:line_items, :exists?).and_return(false)
      expect(order.checkout_allowed?).to be false
    end
  end

  context '#amount' do
    before do
      @order = create(:order)
      @order.line_items = [create(:line_item, price: 1.0, quantity: 2),
                           create(:line_item, price: 1.0, quantity: 1)]
    end
    it 'returns the correct lum sum of items' do
      expect(@order.amount).to eq(3.0)
    end
  end

  context '#tax_total' do
    it 'adds included tax and additional tax' do
      allow(order).to receive_messages(additional_tax_total: 10, included_tax_total: 20)

      expect(order.tax_total).to eq 30
    end
  end

  describe '#pre_tax_item_amount' do
    it "sums all of the line items' pre tax amounts" do
      subject.line_items = [
        Spree::LineItem.new(price: 10, quantity: 2, pre_tax_amount: 5.0),
        Spree::LineItem.new(price: 30, quantity: 1, pre_tax_amount: 14.0)
      ]

      expect(subject.pre_tax_item_amount).to eq 19.0
    end
  end

  describe '#quantity' do
    let(:order) { create :order_with_line_items, line_items_count: 3 }

    it 'sums the quantity of all line items' do
      expect(order.quantity).to eq 3
    end
  end

  describe '#validate_payments_attributes' do
    let(:payment_method) { create(:credit_card_payment_method) }
    let(:attributes) do
      [{ amount: 50, payment_method_id: payment_method.id }]
    end

    context 'with existing payment method' do
      it "doesn't raise error and returns collection" do
        expect(order.validate_payments_attributes(attributes)).to eq attributes
      end
    end

    context 'not existing payment method' do
      let(:payment_method) { create(:credit_card_payment_method, display_on: 'backend') }

      it 'raises RecordNotFound' do
        expect { order.validate_payments_attributes(attributes) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end