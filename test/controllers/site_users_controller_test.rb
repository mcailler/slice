require 'test_helper'

class SiteUsersControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @site_user = site_users(:one)
  end

  test "should resend site invitation" do
    post :resend, id: @site_user, project_id: @project, format: 'js'

    assert_not_nil assigns(:site_user)
    assert_not_nil assigns(:site)
    assert_template 'resend'
  end

  test "should not resend site invitation with invalid id" do
    post :resend, id: -1, project_id: @project, format: 'js'

    assert_nil assigns(:site_user)
    assert_nil assigns(:site)
    assert_response :success
  end

  test "should accept site user" do
    login(users(:two))
    session[:site_invite_token] = site_users(:invited).invite_token
    get :accept, project_id: @project

    assert_not_nil assigns(:site_user)
    assert_equal users(:two), assigns(:site_user).user
    assert_equal "You have been successfully been added to the site.", flash[:notice]
    assert_redirected_to [assigns(:site_user).site.project, assigns(:site_user).site]
  end

  test "should accept existing site user" do
    session[:site_invite_token] = site_users(:two).invite_token
    get :accept, project_id: @project

    assert_not_nil assigns(:site_user)
    assert_equal users(:valid), assigns(:site_user).user
    assert_equal "You have already been added to #{assigns(:site_user).site.name}.", flash[:notice]
    assert_redirected_to [assigns(:site_user).site.project, assigns(:site_user).site]
  end

  test "should not accept invalid token for site user" do
    session[:site_invite_token] = 'imaninvalidtoken'
    get :accept, project_id: @project

    assert_nil assigns(:site_user)
    assert_equal 'Invalid invitation token.', flash[:alert]
    assert_redirected_to root_path
  end

  test "should not accept site user if invite token is already claimed" do
    login(users(:two))
    session[:site_invite_token] = 'validintwo'
    get :accept, project_id: @project

    assert_not_nil assigns(:site_user)
    assert_not_equal users(:two), assigns(:site_user).user
    assert_equal "This invite has already been claimed.", flash[:alert]
    assert_redirected_to root_path
  end

  test "should destroy site_user" do
    assert_difference('SiteUser.count', -1) do
      delete :destroy, id: @site_user, project_id: @project, format: 'js'
    end

    assert_not_nil assigns(:site_user)
    assert_not_nil assigns(:site)

    assert_template 'projects/members'
    assert_response :success
  end

  test "should not destroy site_user as a site user" do
    login(users(:site_one_viewer))
    assert_difference('SiteUser.count', 0) do
      delete :destroy, id: @site_user, project_id: @project, format: 'js'
    end

    assert_not_nil assigns(:site_user)
    assert_nil assigns(:site)

    assert_response :success
  end

  test "should destroy site_user if signed in user is the selected site user" do
    login(users(:site_one_viewer))
    assert_difference('SiteUser.count', -1) do
      delete :destroy, id: site_users(:site_viewer), project_id: @project, format: 'js'
    end

    assert_not_nil assigns(:site_user)
    assert_not_nil assigns(:site)

    assert_template 'projects/members'
    assert_response :success
  end
end
