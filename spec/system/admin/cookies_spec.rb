# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Managing cookies in the admin', type: :system do
  let!(:cookie) { create :cookie, name: "Chocolate Chip", ingredients: "Flour, butter, chocolate" }

  context 'when signed in as a shopper' do
    before { sign_in create(:user) }

    it "doesn't show them the cookies" do
      visit solidus_admin.cookies_path

      expect(page).to have_content "You are not authorized"
      expect(page).to have_no_content "Flour, butter, chocolate"
    end
  end

  context 'when signed in as an admin' do
    before { sign_in create(:admin_user) }

    it 'lists the cookies' do
      visit solidus_admin.cookies_path

      expect(page).to have_css "h1", text: "Cookies"
      within("tr", text: "Chocolate Chip") { expect(page).to have_content "Flour, butter, chocolate" }
    end

    it 'adds a cookie', js: true do
      visit solidus_admin.cookies_path
      click_on "Add Cookie"

      within("dialog") do
        fill_in "Name", with: "Oatmeal Raisin"
        fill_in "Ingredients", with: "Oats, raisins, butter"
        click_on "Add Cookie"
      end

      expect(page).to have_content "Cookie added."
      within("tr", text: "Oatmeal Raisin") { expect(page).to have_content "Oats, raisins, butter" }
    end

    it 'explains why a cookie without ingredients was not added', js: true do
      visit solidus_admin.cookies_path
      click_on "Add Cookie"

      within("dialog") do
        fill_in "Name", with: "Mystery"
        click_on "Add Cookie"

        expect(page).to have_content "can't be blank"
      end
      expect(Cookie.where(name: "Mystery")).to be_empty
    end

    it 'edits a cookie', js: true do
      visit solidus_admin.cookies_path
      click_on "Chocolate Chip"

      within("dialog") do
        fill_in "Name", with: "Double Chocolate Chip"
        click_on "Update Cookie"
      end

      expect(page).to have_content "Cookie updated."
      expect(cookie.reload.name).to eq "Double Chocolate Chip"
    end

    it 'deletes a cookie', js: true do
      visit solidus_admin.cookies_path

      within("tr", text: "Chocolate Chip") { find("input[type=checkbox]").check }
      click_on "Delete"
      find("#confirm-accept").click

      expect(page).to have_content "Cookies deleted."
      expect(Cookie.exists?(cookie.id)).to be false
    end
  end
end
