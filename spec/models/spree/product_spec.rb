require 'rails_helper'
module ThirdParty
    class Extension < Spree::Base
      # nasty hack so we don't have to create a table to back this fake model
      self.table_name = 'spree_products'
    end
  end

    RSpec.describe Spree::Product, type: :model do
        
            context 'product instance' do
              let(:product) { create(:product) }
              let(:variant) { create(:variant, product: product) }
          
              context '#duplicate' do
                before do
                  allow(product).to receive_messages taxons: [create(:taxon)]
                end
          
              context 'master variant' do
                context 'when master variant changed' do
                  before do
                    product.master.sku = 'Something changed'
                  end
          
                  it 'saves the master' do
                    expect(product.master).to receive(:save!)
                    product.save
                  end
                end
          
                context 'when master default price changed' do
                  before do
                    master = product.master
                    master.default_price.price = 11
                    master.save!
                    product.master.default_price.price = 12
                  end
          
                  it 'saves the master' do
                    expect(product.master).to receive(:save!)
                    product.save
                  end
          
                  it 'saves the default price' do
                    expect(product.master.default_price).to receive(:save)
                    product.save
                  end
                end
          
                context "when master variant and price haven't changed" do
                  it 'does not save the master' do
                    expect(product.master).not_to receive(:save!)
                    product.save
                  end
                end
              end
          
              context 'product has no variants' do
                context '#destroy' do
                  it 'sets deleted_at value' do
                    product.destroy
                    expect(product.deleted_at).not_to be_nil
                    expect(product.master.reload.deleted_at).not_to be_nil
                  end
                end
              end
          
              context 'product has variants' do
                before do
                  create(:variant, product: product)
                end
          
                context '#destroy' do
                  it 'sets deleted_at value' do
                    product.destroy
                    expect(product.deleted_at).not_to be_nil
                    expect(product.variants_including_master.all? { |v| !v.deleted_at.nil? }).to be true
                  end
                end
              end
          
              context '#price' do
                it 'strips non-price characters' do
                  product.price = '$10'
                  expect(product.price).to eq(10.0)
                end
              end
          
              context '#display_price' do
                before { product.price = 10.55 }
          
                it 'shows the amount' do
                  expect(product.display_price.to_s).to eq('$10.55')
                end            
              end
          
              context '#available?' do
                it 'is available if date is in the past' do
                  product.available_on = 1.day.ago
                  expect(product).to be_available
                end
          
                it 'is not available if date is nil or in the future' do
                  product.available_on = nil
                  expect(product).not_to be_available
          
                  product.available_on = 1.day.from_now
                  expect(product).not_to be_available
                end
          
                it 'is not available if destroyed' do
                  product.destroy
                  expect(product).not_to be_available
                end
              end
                   
              context 'variants_and_option_values' do
                let!(:high) { create(:variant, product: product) }
                let!(:low) { create(:variant, product: product) }
          
                before { high.option_values.destroy_all }
          
                it 'returns only variants with option values' do
                  expect(product.variants_and_option_values).to eq([low])
                end
              end
                   
              context 'has stock items' do
                it 'can retrieve stock items' do
                  expect(product.master.stock_items.first).not_to be_nil
                  expect(product.stock_items.first).not_to be_nil
                end
              end
          
              context 'slugs' do
                it 'normalizes slug on update validation' do
                  product.slug = 'hey//joe'
                  product.valid?
                  expect(product.slug).not_to match '/'
                end
          
                context 'when product destroyed' do
                  it 'renames slug' do
                    expect { product.destroy }.to change(product, :slug)
                  end
          
                  context 'when slug is already at or near max length' do
                    before do
                      product.slug = 'x' * 255
                      product.save!
                    end
          
                    it 'truncates renamed slug to ensure it remains within length limit' do
                      product.destroy
                      expect(product.slug.length).to eql 255
                    end
                  end
                end
          
                it 'validates slug uniqueness' do
                  existing_product = product
                  new_product = create(:product)
                  new_product.slug = existing_product.slug
          
                  expect(new_product.valid?).to eq false
                end
          
                it "falls back to 'name-sku' for slug if regular name-based slug already in use" do
                  product1 = build(:product)
                  product1.name = 'test'
                  product1.sku = '123'
                  product1.save!
          
                  product2 = build(:product)
                  product2.name = 'test'
                  product2.sku = '456'
                  product2.save!
          
                  expect(product2.slug).to eq 'test-456'
                end
              end
                             
            context 'properties' do
              let(:product) { create(:product) }
          
              context 'optional property_presentation' do
                subject { Spree::Property.where(name: 'foo').first.presentation }
          
                let(:name) { 'foo' }
                let(:presentation) { 'baz' }
          
                describe 'is not used' do
                  before { product.set_property(name, 'bar') }
                  it { is_expected.to eq name }
                end
          
                describe 'is used' do
                  before { product.set_property(name, 'bar', presentation) }
                  it { is_expected.to eq presentation }
                end
              end
            end
          
            context '#create' do
              let!(:prototype) { create(:prototype) }
              let!(:product) { Spree::Product.new(name: 'Foo', price: 1.99, shipping_category_id: create(:shipping_category).id) }
          
              before { product.prototype_id = prototype.id }
          
              context 'when prototype is supplied' do
                it 'creates properties based on the prototype' do
                  product.save
                  expect(product.properties.count).to eq(1)
                end
              end
          
              context 'when prototype with option types is supplied' do
                def build_option_type_with_values(name, values)
                  values.each_with_object(create(:option_type, name: name)) do |val, ot|
                    ot.option_values.create(name: val.downcase, presentation: val)
                  end
                end
          
                let(:prototype) do
                  size = build_option_type_with_values('size', %w(Small Medium Large))
                  create(:prototype, name: 'Size', option_types: [size])
                end
          
                let(:option_values_hash) do
                  hash = {}
                  prototype.option_types.each do |i|
                    hash[i.id.to_s] = i.option_value_ids
                  end
                  hash
                end
          
                it 'creates option types based on the prototype' do
                  product.save
                  expect(product.option_type_ids.length).to eq(1)
                  expect(product.option_type_ids).to eq(prototype.option_type_ids)
                end
          
                it 'creates product option types based on the prototype' do
                  product.save
                  expect(product.product_option_types.pluck(:option_type_id)).to eq(prototype.option_type_ids)
                end
          
                it 'creates variants from an option values hash with one option type' do
                  product.option_values_hash = option_values_hash
                  product.save
                  expect(product.variants.length).to eq(3)
                end
          
                it 'stills create variants when option_values_hash is given but prototype id is nil' do
                  product.option_values_hash = option_values_hash
                  product.prototype_id = nil
                  product.save
                  product.reload
                  expect(product.option_type_ids.length).to eq(1)
                  expect(product.option_type_ids).to eq(prototype.option_type_ids)
                  expect(product.variants.length).to eq(3)
                end
          
                it 'creates variants from an option values hash with multiple option types' do
                  color = build_option_type_with_values('color', %w(Red Green Blue))
                  logo  = build_option_type_with_values('logo', %w(Ruby Rails Nginx))
                  option_values_hash[color.id.to_s] = color.option_value_ids
                  option_values_hash[logo.id.to_s] = logo.option_value_ids
                  product.option_values_hash = option_values_hash
                  product.save
                  product.reload
                  expect(product.option_type_ids.length).to eq(3)
                  expect(product.variants.length).to eq(27)
                end
              end
            end
          
            context '#images' do
              let(:product) { create(:product) }
              let(:image) { File.open(File.expand_path('../../../fixtures/test.png', __FILE__)) }
              let(:params) { { viewable_id: product.master.id, viewable_type: 'Spree::Variant', attachment: image, alt: 'position 2', position: 2 } }
          
              before do
                Spree::Image.create(params)
                Spree::Image.create(params.merge(alt: 'position 1', position: 1))
                Spree::Image.create(params.merge(viewable_type: 'ThirdParty::Extension', alt: 'position 1', position: 2))
              end
          
              it 'only looks for variant images' do
                expect(product.images.size).to eq(2)
              end
          
              it 'is sorted by position' do
                expect(product.images.pluck(:alt)).to eq(['position 1', 'position 2'])
              end
            end
          
            context '#validate_master when duplicate SKUs entered' do
              subject { second_product }
          
              let!(:first_product) { create(:product, sku: 'a-sku') }
              let(:second_product) { build(:product, sku: 'a-sku') }
          
              it { is_expected.to be_invalid }
            end
          
            it 'initializes a master variant when building a product' do
              product = Spree::Product.new
              expect(product.master.is_master).to be true
            end
          
            context '#discontinue!' do
              let(:product) { create(:product, sku: 'a-sku') }
          
              it 'sets the discontinued' do
                product.discontinue!
                product.reload
                expect(product.discontinued?).to be(true)
              end
            end
          
            context '#discontinued?' do
              let(:product_live) { build(:product, sku: 'a-sku') }
              let(:product_discontinued) { build(:product, sku: 'a-sku', discontinue_on: Time.now - 1.day) }
          
              it 'is false' do
                expect(product_live.discontinued?).to be(false)
              end
          
              it 'is true' do
                expect(product_discontinued.discontinued?).to be(true)
              end
            end
                    
            describe '#ensure_no_line_items' do
              let(:product) { create(:product) }
              let!(:line_item) { create(:line_item, variant: product.master) }
          
              it 'adds error on product destroy' do
                expect(product.destroy).to eq false
                expect(product.errors[:base]).to include I18n.t('activerecord.errors.models.spree/product.attributes.base.cannot_destroy_if_attached_to_line_items')
              end
            end
        end
    end
end