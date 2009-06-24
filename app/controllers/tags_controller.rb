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
      redirect_to :action => :index, :tag_type => @tag.tag_type.id
    else
      flash[:error] = @tag.errors.full_messages.to_s
      redirect_to :tags, :tag_type => params[:tag_type]
    end
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
      redirect_to(:action => 'index', :id => @tag.object_id)
    else
      render :action => "edit"
    end
  end

  def destroy
    @tag = Tag.find(params[:id])
    tag_type_id = if @tag then @tag.tag_type.id else "" end

    puts "destroying #{@tag}"

    if @tag.activities.empty?
      @tag.destroy
      flash[:notice] = "Tag removed"
      redirect_to :action => :index, :tag_type => tag_type_id     
    else
      flash[:error] = "Tag is used by activity and cannot be removed"
      redirect_to :action => :index, :tag_type => tag_type_id 
    end
  end

end