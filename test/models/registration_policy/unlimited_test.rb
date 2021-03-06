require 'test_helper'

class RegistrationPolicy::UnlimitedTest < ActiveSupport::TestCase
  let(:event_run) { FactoryBot.create :run }
  let(:free_ticket_type) { FactoryBot.create(:free_ticket_type, convention: event_run.event.convention) }
  subject { RegistrationPolicy.unlimited }

  it 'is valid' do
    subject.must_be :valid?
  end

  it 'has one bucket' do
    subject.buckets.size.must_equal 1
  end

  it 'allows all signups' do
    bucket_key = subject.buckets.first.key

    3.times do |_i|
      event_run.signups.reload

      signup_user_con_profile = FactoryBot.create(:user_con_profile, convention: event_run.event.convention)
      FactoryBot.create(:ticket, user_con_profile: signup_user_con_profile, ticket_type: free_ticket_type)
      result = EventSignupService.new(signup_user_con_profile, event_run, bucket_key, signup_user_con_profile.user).call
      result.must_be :success?
    end
  end

  it 'serializes and deserializes' do
    json = subject.to_json
    deserialized = RegistrationPolicy.new.from_json(json)
    deserialized.buckets.must_equal subject.buckets
  end
end
