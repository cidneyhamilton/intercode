require 'parallel'

class DatabaseSanitizer
  attr_reader :email_blacklist

  def initialize(email_blacklist)
    @email_blacklist = Set.new(email_blacklist)
  end

  def sanitize_user(user)
    return if email_blacklist.include?(user.email)

    first_name = Faker::Name.first_name

    user.update!(
      first_name: first_name,
      last_name: Faker::Name.last_name,
      email: Faker::Internet.safe_email("#{first_name}#{user.id}"),
      password: 'password',
      legacy_password_md5: nil
    )
  end

  def sanitize_user_con_profile(user_con_profile)
    user = user_con_profile.user
    return if email_blacklist.include?(user.email)

    sanitized_fields = {
      first_name: user.first_name,
      last_name: user.last_name,
      nickname: Faker::Lorem.word.titleize,
      birth_date: Faker::Time.between(Date.today - 70.years, Date.today - 16.years),
      address: Faker::Address.street_address([true, false, false, false].sample),
      city: Faker::Address.city,
      state: Faker::Address.state_abbr,
      zipcode: Faker::Address.postcode,
      country: Faker::Address.country,
      day_phone: Faker::PhoneNumber.phone_number,
      evening_phone: Faker::PhoneNumber.phone_number,
      best_call_time: Faker::Lorem.sentence
    }

    sanitized_present_fields = sanitized_fields.select do |key, _|
      user_con_profile.public_send(key).present?
    end

    user_con_profile.update!(sanitized_present_fields)
  end
end

desc 'Sanitize the local copy of the database by anonymizing user data'
task sanitize_db: :environment do
  require 'faker'

  email_blacklist = [
    'natbudin@gmail.com',
    'j.l.unrein@gmail.com',
    'kenright@iit.edu',
    'barry.tannenbaum@gmail.com',
    'david@rigitech.com',
    'elfracal@electric-monk.net'
  ]
  sanitizer = DatabaseSanitizer.new(email_blacklist)

  Parallel.each(User.all, in_processes: Parallel.processor_count) do |user|
    puts "Sanitizing user #{user.id}"
    sanitizer.sanitize_user(user)
  end

  ActiveRecord::Base.connection.reconnect!

  scope = UserConProfile.includes(:user).all
  Parallel.each(scope, in_processes: Parallel.processor_count) do |user_con_profile|
    puts "Sanitizing user con profile #{user_con_profile.id}"

    sanitizer.sanitize_user_con_profile(user_con_profile)
  end
end
