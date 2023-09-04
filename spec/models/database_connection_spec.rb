# spec/models/database_connection_spec.rb
require 'rails_helper'

RSpec.describe 'Database Connection', type: :model do
  it 'successfully connects to the database' do
    expect { ActiveRecord::Base.connection }.not_to raise_error
  end
end
