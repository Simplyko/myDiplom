require 'rails_helper'

RSpec.describe "Landing page", type: :feature, js: true do
 let!(:product1) {create(:product, name: "product" , avg_rating: 5, available_on: 1.year.ago)}

  it "have product on landing page with rating" do
    visit "/"
    expect(page).to have_content "Product"
    expect(page).to have_css('a', text: '5 stars')
    Capybara::Screenshot.autosave_on_failure = true
  end
end