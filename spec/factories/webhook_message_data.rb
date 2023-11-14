# spec/factories/webhook_message_data.rb

FactoryBot.define do
  factory :message_data, class: Hash do
    skip_create # since it's not an ActiveRecord

    message_id { 100 }
    from do
      {
        "id" => 3334445550,
        "is_bot" => false,
        "first_name" => "Oleg",
        "language_code" => "ru"
      }
    end
    chat do
      {
        "id" => 3334445550,
        "first_name" => "Oleg",
        "type" => "private"
      }
    end
    date { 1693108432 }
    text { "Good date" }

    initialize_with { attributes.stringify_keys }
  end
end