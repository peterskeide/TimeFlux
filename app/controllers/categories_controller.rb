class CategoriesController < ApplicationController
  
  before_filter :check_authentication
  
  def index
    @categories = Category.find(:all)  
  end
    
  def create
    @category = Category.new(params[:category])
    if @category.save
      flash[:notice] = "Category successfully created"
      redirect_to :categories   
    else
      flash[:error] = @category.errors.full_messages.to_s
      redirect_to :categories
    end
  end
  
  def destroy
    @category = Category.find(params[:id])
    if not @category.activities.empty?
      flash[:error] = "Category cannot be removed because it has associated activities"
      redirect_to :categories
    else
      @category.destroy
      flash[:notice] = "Category removed"
      redirect_to :categories
    end
  end
  
end