class EventDrop < Liquid::Drop
  include Rails.application.routes.url_helpers

  attr_reader :event
  delegate :id, :title, :team_member_name, :event_proposal, to: :event

  def initialize(event)
    @event = event
  end

  def team_member_user_con_profiles
    event.team_members.map(&:user_con_profile)
  end

  def url
    event_path(event)
  end
end
