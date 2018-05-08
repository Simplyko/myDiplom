require "rails_helper"

RSpec.feature "User SignUp", type: :feature do

    scenario "User create new account" do
        visit "/signup"
        fill_in "Email", with: "user@example.com"
        fill_in "Password", with: "password"
        fill_in "Password Confirmation", with: "password"

        click_button  "Create" 
        expect(page).to have_text("Welcome! You have signed up successfully.")
    end
    
end

RSpec.feature "User SignIn", type: :feature do

        let!(:user) {create(:user, email: "user@example.com", password: "password")}

        scenario "User Logged in" do

        visit "/login"
        fill_in "Email", with: "user@example.com"
        fill_in "Password", with: "password"

        click_button  "Login" 
        expect(page).to have_text("Logged in successfully")
    end
    
end