class TagTypesController < ApplicationController

  before_filter :check_authentication, :check_admin

  def index
    @tag_types = TagType.find(:all)
  end

  def create
    @tag_types = TagType.new(params[:tag_type])
    if @tag_types.save
      flash[:notice] = "Tag Type successfully created"
      redirect_to :tag_types
    else
      flash[:error] = @tag_types.errors.full_messages.to_s
      redirect_to :tag_types
    end
  end

  def edit
    @tag_type = TagType.find(params[:id])
  end

  def update
    @tag_type = TagType.find(params[:id])
    if @tag_type.update_attributes(params[:tag_type])
      flash[:notice] = "Tag category was successfully updated."
      redirect_to :action => "index"
    else
      render :action => "edit"
    end
  end

  def destroy
    @tag_types = TagType.find(params[:id])
    if @tag_types.tags.empty?
      @tag_types.destroy
      flash[:notice] = "Tag Type removed"
      redirect_to :tag_types          
    else
      flash[:error] = "Tag Type is in use and cannot be removed"
      redirect_to :tag_types
    end
  end
  
end