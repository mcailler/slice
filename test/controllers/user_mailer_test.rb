require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  test "notify system admin email" do
    valid = users(:valid)
    admin = users(:admin)

    # Send the email, then test that it got queued
    email = UserMailer.notify_system_admin(admin, valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [admin.email], email.to
    assert_equal "#{valid.name} Signed Up", email.subject
    assert_match(/#{valid.name} \[#{valid.email}\] has signed up for an account\./, email.encoded)
  end

  test "status activated email" do
    valid = users(:valid)

    # Send the email, then test that it got queued
    email = UserMailer.status_activated(valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [valid.email], email.to
    assert_equal "#{valid.name}'s Account Activated", email.subject
    assert_match(/Your account \[#{valid.email}\] has been activated\./, email.encoded)
  end

  test "sheet receipt email" do
    sheet_email = sheet_emails(:one)

    # Send the email, then test that it got queued
    email = UserMailer.sheet_receipt(sheet_email).deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal ['to@example.com'], email.to
    assert_equal "Sheet Receipt Subject", email.subject
    assert_match(/Email Body/, email.encoded)
  end

  test "user invited to site email" do
    site_user = site_users(:invited)

    email = UserMailer.invite_user_to_site(site_user).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [site_user.invite_email], email.to
    assert_equal "#{site_user.creator.name} Invites You to View Site #{site_user.site.name}", email.subject
    assert_match(/#{site_user.creator.name} has invited you to Site #{site_user.site.name}/, email.encoded)
  end

  test "user added to project email" do
    project_user = project_users(:one)

    email = UserMailer.user_added_to_project(project_user).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [project_user.user.email], email.to
    assert_equal "#{project_user.creator.name} Allows You to View Project #{project_user.project.name}", email.subject
    assert_match(/#{project_user.creator.name} has added you to Project #{project_user.project.name}/, email.encoded)
  end

  test "user invited to project email" do
    project_user = project_users(:invited)

    email = UserMailer.invite_user_to_project(project_user).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [project_user.invite_email], email.to
    assert_equal "#{project_user.creator.name} Invites You to View Project #{project_user.project.name}", email.subject
    assert_match(/#{project_user.creator.name} has invited you to Project #{project_user.project.name}/, email.encoded)
  end

  test "sheet completion request email" do
    sheet = sheets(:external)

    email = UserMailer.sheet_completion_request(sheet, 'external_user@example.com').deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [sheet.last_user.email], email.to
    assert_equal "Request to Fill Out #{sheet.design.name}", email.subject
    assert_match(/#{sheet.last_user.name} has requested that you fill out:/, email.encoded)
    assert_match(/Your feedback is important. Please click the link below to complete the form:/, email.encoded)
  end

  test "survey completed email" do
    sheet = sheets(:external)

    email = UserMailer.survey_completed(sheet).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [sheet.user.email], email.to
    assert_equal "#{sheet.subject.subject_code} Submitted #{sheet.design.name}", email.subject
    assert_match(/#{sheet.subject.subject_code} has completed a survey that you requested for #{sheet.name}\. You can view the completed sheet here:/, email.encoded)
  end

  test "export ready email" do
    export = exports(:one)

    email = UserMailer.export_ready(export).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [export.user.email], email.to
    assert_equal "Your Data Export for #{export.project.name} is now Ready", email.subject
    assert_match(/The data export you requested for #{export.project.name} is now ready for download\./, email.encoded)
  end

end