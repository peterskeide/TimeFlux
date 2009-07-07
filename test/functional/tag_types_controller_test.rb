require 'test_helper'

class TagTypesControllerTest < ActionController::TestCase

    context 'Logged in as Bob' do

    setup do
      login_as(:bob)
    end

    context "With tag-types" do

      context "a GET to :index" do
        setup { get :index }
        should_render_template :index
        should_not_set_the_flash
      end

      context "a POST to :create" do
        setup { post :create, :tag_type => {:name => 'Payment Agreement'} }
        should_redirect_to("Index") { "/tag_types" }
        should_set_the_flash_to(/created/i)
      end

      context "destroying a tag-type in use" do
        setup { post :destroy, :id => tag_types(:project) }
        should_redirect_to("Index") { "/tag_types" }
        should_set_the_flash_to(/is in use/i)
      end

      context "destroying a tag-type" do
        setup {
          post :create, :tag_type => {:name => 'Payment Agreement'}
          new_tag_type = TagType.find_by_name 'Payment Agreement'
          post :destroy, :id => new_tag_type.id
        }
        should_redirect_to("Index") { "/tag_types" }
        should_set_the_flash_to("Tag Type removed")
      end

    end
  end

  context 'Logged in as bill on GET to :index' do
    setup { login_as(:bill); get :index }
    should_redirect_to("Time Entries") { "/time_entries" }
  end

  context "Not logged in on GET to :index" do
    setup { get :index }
    should_redirect_to("Login page") { "/user_sessions/new" }
  end



end
