# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :signup do
    run
    user_con_profile
    state 'confirmed'
    counted true
    bucket_key nil
    updated_by nil
  end
end
