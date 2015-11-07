class EventsController < BaseControllers::VirtualHost
  load_and_authorize_resource through: :convention

  # Display form to propose a new LARP.  Create a new LARP event to initialize
  # the form
  def new
  end

  # Write information from the new LARP to the database
  def create
    @larp.convention = convention
    @larp.user = current_user
    @larp.updated_by = current_user
    if @larp.save
      flash[:notice]="Thank you for submitting your LARP"
      redirect_to event_path(@larp)
    else
      render 'new'
    end
  end

  # Edit information about a LARP. The id is specified as part of the URL
  def edit
  end

  # Update information about a LARP to the database
  def update
    @event.updated_by = current_user

    if @event.update_attributes(event_params)
      redirect_to action: 'show'
    else
      render 'edit'
    end
  end

  # List the available LARPs
  def index
    @events = @events.accepted.order(:title)
  end

  # Show information about a LARP. The id is specified as part of the URL
  def show
    @team_members = @event.team_members.includes(:user).visible.sort_by { |m| m.user.name_inverted }
  end

  # Permit access to fields that can be updated
  def event_params
    params.require(:event).permit(:author,
                                  :description,
                                  :email,
                                  :length_seconds,
                                  :organization,
                                  :short_blurb,
                                  :title,
                                  :url)
  end
end
