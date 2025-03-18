RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

# Load all factory definitions
Dir[Rails.root.join('spec/factories/**/*.rb')].each { |f| require f }

# Configure FactoryBot
FactoryBot.define do
  # Define sequences here if needed
  sequence :email do |n|
    "user#{n}@example.com"
  end
  
  sequence :username do |n|
    "user#{n}"
  end
end 