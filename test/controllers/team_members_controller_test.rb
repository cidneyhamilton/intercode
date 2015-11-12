require 'test_helper'

describe TeamMembersController do
  let(:team_member) { FactoryGirl.create(:team_member) }
  let(:event) { team_member.event }
  let(:convention) { event.convention }

  setup do
    set_convention convention
    sign_in team_member.user

    team_member
  end

  test "should get index" do
    get :index, event_id: event
    assert_response :success
    assert_not_nil assigns(:team_members)
  end

  test "should get new" do
    get :new, event_id: event
    assert_response :success
  end

  test "should create team_member" do
    assert_difference('TeamMember.count') do
      post :create, event_id: event, team_member: { user_id: FactoryGirl.create(:user).id }
    end

    assert_redirected_to [event, :team_members]
  end

  test "should get edit" do
    get :edit, event_id: event, id: team_member
    assert_response :success
  end

  test "should update team_member" do
    refute team_member.display?
    patch :update, event_id: event, id: team_member, team_member: { display: true }
    assert team_member.reload.display?

    assert_redirected_to [event, :team_members]
  end

  test "should destroy team_member" do
    assert_difference('TeamMember.count', -1) do
      delete :destroy, event_id: event, id: team_member
    end

    assert_redirected_to [event, :team_members]
  end
end