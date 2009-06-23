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
    @tags = Tag.new(params[:tag])
    if @tags.save
      flash[:notice] = "Tag successfully created"
      redirect_to :tags
    else
      flash[:error] = @tags.errors.full_messages.to_s
      redirect_to :tags
    end
  end

  def show
    @tag = Tag.find(params[:id])
  end

  #TODO
  def destroy
    @tags = Tag.find(params[:id])
    if false #not @tags.activities.empty?
      flash[:error] = "Tag cannot be removed"
      redirect_to :tags
    else
      @tags.destroy
      flash[:notice] = "Tag removed"
      redirect_to :tags
    end
  end

end