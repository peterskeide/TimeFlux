class TagTypesController < ApplicationController

  before_filter :check_authentication, :check_admin

  def index
    @tag_types = TagType.find(:all)
  end

  def create
    tag_type = TagType.new(params[:tag_type])
    if tag_type.save
      flash[:notice] = "Tag Type successfully created"
    else
      flash[:error] = tag_type.errors.full_messages.to_s
    end
    redirect_to :tag_types
  end

  def edit
    @tag_type = TagType.find(params[:id])
    @icons = Dir.glob("public/images/led-icons/*.png")
    @icons.each { |i| 
      i.sub! "public/images/led-icons/", ''
      i.sub! ".png", ''
    }
  end

  def update
    @tag_type = TagType.find(params[:id])

    if @tag_type.update_attributes(params[:tag_type])
      flash[:notice] = "Tag category was successfully updated."
      redirect_to :action => "index"
    else
      flash[:error] = @tag_type.errors.full_messages.to_s
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

  def update_icon
    if request.xhr?
      render :partial => 'icon', :locals => { :icon => params[:icon] }
    else
      @tag_type = TagType.find(params[:id])
      @icons = Dir.glob("public/images/led-icons/*.png")
      @icons.each { |i| 
        i.sub! "public/images/led-icons/", ''
        i.sub! ".png", ''
        @tag_type.icon = i if params["#{i}.x".to_sym]
      }
      render :edit
    end
  end
  
end