class TicketTypeDrop < Liquid::Drop
  attr_reader :ticket_type
  delegate :id, :name, :description, :price_change, :next_price_change,
    :publicly_available, :maximum_event_provided_tickets, to: :ticket_type

  def initialize(ticket_type)
    @ticket_type = ticket_type
  end

  def pricing_schedule
    ScheduledValueDrop.new(ticket_type.pricing_schedule, ticket_type.convention.timezone)
  end

  def price
    ticket_type.price&.format
  end

  def next_price
    ticket_type.next_price&.format
  end
end
