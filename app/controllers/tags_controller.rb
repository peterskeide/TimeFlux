class TagsController < ApplicationController

  before_filter :check_authentication, :check_admin

  def index
    @tag_types = TagType.find(:all)

    if params[:tag_type] && params[:tag_type] != ""
      type = TagType.find(params[:tag_type])
      @tags = type.tags.paginate( :page => params[:page] || 1, :per_page => 20, :order => 'name' )
    else
      @tags = Tag.paginate( :page => params[:page] || 1, :per_page => 20, :order => 'name' )
    end
  end

  def create
    @tag = Tag.new(params[:tag])

    if @tag.save
      flash[:notice] = "Tag successfully created"
    else
      flash[:error] = @tag.errors.full_messages.to_s      
    end
    redirect_to :tags, :tag_type => params[:tag_type]
  end

  def show
    @tag = Tag.find(params[:id])
  end

  def edit
    @tag = Tag.find(params[:id])
    @tag_types = TagType.all
  end


  def update
    @tag = Tag.find(params[:id])
    attributes = params[@tag.class.name.underscore]
    if @tag.update_attributes(attributes)
      flash[:notice] = 'Tag was successfully updated.'
      redirect_to :action => 'index', :tag_type => params[:tag_type]
    else
      flash[:error] = @tag.errors.full_messages.to_s
      render :action => "edit"
    end
  end

  def destroy
    @tag = Tag.find(params[:id])

    if @tag.activities.empty?
      flash[:notice] = "Tag removed"
      @tag.destroy 
    else
      flash[:error] = "Tag is used by activity and cannot be removed"    
    end
    redirect_to :action => :index, :tag_type => params[:tag_type]
  end

  def update_tags
    if params[:tag_type] && params[:tag_type] != ""
      type = TagType.find(params[:tag_type])
      tags = type.tags.paginate( :page => 1, :per_page => 20, :order => 'name' )
    else
      tags = Tag.paginate( :page => params[:page] || 1, :per_page => 20, :order => 'name' )
    end


    render :partial => 'tags', :locals => { :tags => tags_for_tag_type(params[:tag_type]) }
  end

  private

  def tags_for_tag_type(tag_type_id, page=1)
    if tag_type_id && tag_type_id != ""
      TagType.find(tag_type_id).tags.paginate( :page => 1, :per_page => 20, :order => 'name' )
    else
      Tag.paginate( :page => page, :per_page => 20, :order => 'name' )
    end
  end

end