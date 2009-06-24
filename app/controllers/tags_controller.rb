class TagsController < ApplicationController

  before_filter :check_authentication

  def index
    @tag_types = TagType.find(:all)
    @tags = Tag.find(:all)
    if params[:tag_type]
      type = TagType.find(params[:tag_type])
      @tags = type.tags
    else
      @tags = Tag.find(:all)
    end
  end

  def create
    @tag = Tag.new(params[:tag])
    if @tag.save
      flash[:notice] = "Tag successfully created"
      #redirect_to :tags, :tag_type => params[:tag_type]
      redirect_to :action => :index, :tag_type => @tag.tag_type.id
    else
      flash[:error] = @tag.errors.full_messages.to_s
      redirect_to :tags, :tag_type => params[:tag_type]
    end
  end

  def show
    @tag = Tag.find(params[:id])
  end

  #TODO: when tags may not be removed...
  def destroy
    @tag = Tag.find(params[:id])
    if @tag.activities.empty?
      tag_type_id = @tag.tag_type.id
      @tag.destroy
      flash[:notice] = "Tag removed"
      redirect_to :action => :index, :tag_type => tag_type_id     
    else
      flash[:error] = "Tag is used by activity and cannot be removed"
      redirect_to :tags
    end
  end

end