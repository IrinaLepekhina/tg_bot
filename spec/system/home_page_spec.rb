# frozen_string_literal: true
# spec/system/home_page_spec.rb

require 'rails_helper'

RSpec.describe 'home page' do
  it 'welcome message' do
    visit('/')
    expect(page).to have_content('Welcome')
  end
end
 