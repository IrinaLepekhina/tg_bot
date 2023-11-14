# spec/factories/transaction_input.rb

FactoryBot.define do
  factory :transaction_input, class: Hash do
    skip_create

    bot_id          { "muul" }
    content         { Faker::Lorem.sentence }
    conversation_id { Faker::Number.number(digits: 9) }
    date            { Faker::Time.backward(days: 14, period: :all).to_i }
    chat_id         { Faker::Number.number(digits: 9) }
    first_name      { Faker::Name.first_name }
    from_id         { Faker::Number.number(digits: 9) }
    language_code   { ["en", "ru"].sample }
    message_id      { Faker::Number.number(digits: 9) }
    text            { Faker::Lorem.sentence }
    update_id       { Faker::Number.number(digits: 9) }

    initialize_with { attributes }
  end
end