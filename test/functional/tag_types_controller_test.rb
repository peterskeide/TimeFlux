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

      context "a GET to :edit" do
        setup { get :edit, :id => tag_types(:project) }
        should_render_template :edit
      end

      context "a POST to :create" do
        setup { post :create, :tag_type => {:name => 'Payment Agreement', :mutually_exclusive => false}, :icon => 'dollar' }
        should_redirect_to("Index") { "/tag_types" }
        should_set_the_flash_to(/created/i)
      end

      context "updating a tag-type" do
        setup { post :update, :id => tag_types(:project), :name => "Konklave" }
        should_redirect_to("Index") { "/tag_types" }
        should_set_the_flash_to(/updated/i)
      end

      context "destroying a tag-type in use" do
        setup { post :destroy, :id => tag_types(:project) }
        should_redirect_to("Index") { "/tag_types" }
        should_set_the_flash_to(/is in use/i)
      end

      context "destroying a tag-type" do
        setup {
          temporary_tag_type = TagType.create(:name => 'Payment Agreement')
          post :destroy, :id => temporary_tag_type.id
        }
        should_redirect_to("Index") { "/tag_types" }
        should_set_the_flash_to("Tag Type removed")
      end

      context "updating the icon - noscript" do
        setup {
          post :update_icon, :id => tag_types(:project), :icon => 'hammer'
        }
        should_render_template :edit
      end

      context "updating the icon - ajax style" do
        setup {
          xhr :post, :update_icon, :id => tag_types(:project), :icon => 'hammer'
        }
        should_render_template :_icon
      end      
 
    end
  end

  context 'Logged in as bill on GET to :index' do
    setup { login_as(:bill); get :index }
    should_redirect_to("Time Entries") { user_time_entries_url(:user_id => users(:bill).id)}
  end

  context "Not logged in on GET to :index" do
    setup { get :index }
    should_redirect_to("Login page") { "/user_sessions/new" }
  end



end
