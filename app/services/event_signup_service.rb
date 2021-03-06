class EventSignupService < ApplicationService
  class Result < ServiceResult
    attr_accessor :signup
  end
  self.result_class = Result

  attr_reader :user_con_profile, :run, :requested_bucket_key, :max_signups_allowed, :whodunit
  delegate :event, to: :run
  delegate :convention, to: :event

  self.validate_manually = true
  validate :signup_count_must_be_allowed
  validate :must_not_have_conflicting_signups
  validate :must_have_ticket
  validate :require_valid_bucket
  validate :require_no_bucket_for_team_member

  include Concerns::ConventionRegistrationFreeze

  def initialize(user_con_profile, run, requested_bucket_key, whodunit, skip_locking: false)
    @user_con_profile = user_con_profile
    @run = run
    @requested_bucket_key = requested_bucket_key
    @whodunit = whodunit
    @skip_locking = skip_locking
  end

  def conflicting_waitlist_signups
    @conflicting_waitlist_signups ||= other_signups.select do |signup|
      signup.waitlisted? && run.overlaps?(signup.run)
    end
  end

  private

  def inner_call
    signup = nil
    with_advisory_lock_unless_skip_locking("run_#{run.id}_signups") do
      return failure(errors) unless valid?

      signup = run.signups.create!(
        run: run,
        bucket_key: actual_bucket.try!(:key),
        requested_bucket_key: requested_bucket_key,
        user_con_profile: user_con_profile,
        counted: counts_towards_total?,
        state: signup_state,
        updated_by: whodunit
      )

      withdraw_user_from_conflicting_waitlist_signups
    end

    notify_team_members(signup)
    success(signup: signup)
  end

  def signup_count_must_be_allowed
    return if team_member?
    @max_signups_allowed = convention.maximum_event_signups.value_at(Time.now)

    case @max_signups_allowed
    when 'not_now', 'not_yet' then errors.add :base, 'Signups are not allowed at this time.'
    else
      unless signup_count_allowed?(user_signup_count + 1)
        errors.add :base,
          "You are already signed up for #{user_signup_count} \
#{'event'.pluralize(user_signup_count)}, which is the maximum allowed at this time."
      end
    end
  end

  def must_not_have_conflicting_signups
    return unless !event.can_play_concurrently? && concurrent_signups.any?
    event_titles = concurrent_signups.map { |signup| signup.event.title }
    verb = (event_titles.size > 1) ? 'conflict' : 'conflicts'
    errors.add :base,
      "You are already signed up for #{event_titles.to_sentence}, which #{verb} \
with #{event.title}."
  end

  def must_have_ticket
    return if user_con_profile.ticket
    errors.add :base, "You must have a valid ticket to #{convention.name} to sign up for events."
  end

  def require_valid_bucket
    return if team_member?

    requested_bucket = run.registration_policy.bucket_with_key(requested_bucket_key)
    return unless !requested_bucket || requested_bucket.anything?

    other_buckets = run.registration_policy.buckets.reject(&:anything?)
    errors.add :base,
      "Please choose one of the following buckets: #{other_buckets.map(&:name).join(', ')}."
  end

  def require_no_bucket_for_team_member
    return unless team_member?
    return unless requested_bucket_key

    errors.add :base, 'Team members must sign up as non-counted'
  end

  def counts_towards_total?
    !team_member?
  end

  def signup_state
    signups = run.signups

    if !team_member? && prioritized_buckets.all? { |bucket| bucket.full?(signups) }
      'waitlisted'
    else
      'confirmed'
    end
  end

  def other_signups
    @other_signups ||= user_con_profile.signups.counted.includes(run: :event)
      .where.not(run_id: run.id).to_a
  end

  def prioritized_buckets
    @prioritized_buckets ||= [
      run.bucket_with_key(requested_bucket_key),
      run.registration_policy.anything_bucket
    ].compact
  end

  def actual_bucket
    return nil if team_member?

    @actual_bucket ||= begin
      signups = run.signups
      prioritized_buckets.find { |bucket| !bucket.full?(signups) }
    end
  end

  def user_signup_count
    other_signups.size
  end

  def team_member?
    return @is_team_member unless @is_team_member.nil?
    @is_team_member = event.team_members.where(user_con_profile_id: user_con_profile.id).any?
  end

  def signup_count_allowed?(signup_count)
    case max_signups_allowed
    when 'unlimited' then true
    when 'not_now', 'not_yet' then false
    else
      signup_count <= max_signups_allowed.to_i
    end
  end

  def concurrent_signups
    @concurrent_signups ||= other_signups.select do |signup|
      other_run = signup.run
      signup.confirmed? && !other_run.event.can_play_concurrently? && run.overlaps?(other_run)
    end
  end

  def withdraw_user_from_conflicting_waitlist_signups
    conflicting_waitlist_signups.each do |conflicting_waitlist_signup|
      EventWithdrawService.new(conflicting_waitlist_signup, whodunit, skip_locking: true).call
    end
  end

  def notify_team_members(signup)
    event.team_members.where(receive_signup_email: true).find_each do |team_member|
      EventSignupMailer.new_signup(signup, team_member).deliver_later
    end
  end
end
