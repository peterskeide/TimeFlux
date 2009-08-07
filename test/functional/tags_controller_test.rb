require 'test_helper'

class TagsControllerTest < ActionController::TestCase

    context 'Logged in as Bob' do

    setup do
      login_as(:bob)
    end

    context "With tags" do

      context "a GET to :index" do
        setup { get :index }
        should_render_template :index
        should_not_set_the_flash
      end

      context "a GET to :index supplying a :tag_type" do
        setup { get :index, :tag_type => tag_types(:project).id }
        should_render_template :index
        should_not_set_the_flash
      end

      context "a POST to :create" do
        setup { post :create, :tag => {:name => 'Internal project', :tag_type_id => tag_types(:project).id} }
        should_redirect_to("Index") { tags_url }
        should_set_the_flash_to(/created/i)
      end

      context "destroying a tag in use" do
        setup { post :destroy, :id => tags(:conduct) }
        should_redirect_to("Index") { "/tags" }
        should_set_the_flash_to(/cannot be removed/i)
      end

      context "destroying a tag" do
        setup {
          temporary_tag = Tag.create(:name => 'Internal project', :tag_type_id => tag_types(:project).id)
          post :destroy, :id => temporary_tag.id
        }
        should_redirect_to("Index") { "/tags" }
        should_set_the_flash_to("Tag removed")
      end

      context "on GET to :show" do
        setup {
          @conduct= tags(:conduct)
          get :show, :id => @conduct.id
        }
        should_render_template :show
        should_not_set_the_flash
      end
      
      context "on GET to :edit" do
        setup {
          get :edit, :id => tags(:conduct).id
        }
        should_render_template :edit
        should_not_set_the_flash
      end
            
      context "on POST to :update" do
        setup {
          post :update, :id => tags(:conduct).id, :tag => {:name => 'Conduct ASA'}
        }
        should_redirect_to("Index") { "/tags" }
        should_set_the_flash_to(/successfully updated/i)
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
