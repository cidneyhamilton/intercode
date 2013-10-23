class Ability
  include CanCan::Ability

  # This class defines access controls.
  # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  def initialize(user)
    
    # All users, anonymous or otherwise, should be allowed to view Cons.
    can :read, Con
    can :read, Page
    
    # Anonymous user permissions end here.
    return unless user
    
    if user.site_admin?
      # Site admins can do any action whatsoever.
      can :manage, :all
    else
      con_staff_scope = Con.joins(:user_con_profiles).where(user_con_profiles: {user_id: user.id, staff: true})
      
      can :manage, Con, con_staff_scope.to_sql do |con|
        user.profile_for(con).staff?
      end
      
      can :manage, Page, Page.where(parent_type: "Con", parent_id: con_staff_scope).to_sql do |page|
        page.parent.is_a?(Con) && user.profile_for(page.parent).staff?
      end
    end
  end
end
