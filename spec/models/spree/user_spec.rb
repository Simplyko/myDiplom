require "rails_helper"

RSpec.describe Spree::User, type: :model do
  
  before(:all) do
    @user1 = create(:user)
  end
  
  it "is valid with valid attributes" do
    expect(@user1).to be_valid
  end
  
  it "is not valid without a password" do 
    user2 = build(:user, password: nil)
    expect(user2).to_not be_valid
  end
  
  it "is not valid without an email" do
    user2 = build(:user, email: nil)
    expect(user2).to_not be_valid
  end

end
