class CustomersController < ApplicationController

  before_filter :check_authentication
  before_filter :check_admin

  def index
    @customers = Customer.paginate :page => params[:page] || 1 , :per_page => 15, :order => 'name'
  end

  def new
    @customer = Customer.new
  end

  def edit
    @customer = Customer.find(params[:id])
  end

  def show
    @customer = Customer.find(params[:id])
  end

  def create
    @customer = Customer.new(params[:customer])

    if @customer.save
      flash[:notice] = 'Customer was successfully created.'
      redirect_to(customers_url)
    else
      render :action => "new"
    end
  end

  def update
    @customer = Customer.find(params[:id])
    if @customer.update_attributes(params[:customer])
      flash[:notice] = 'Customer was successfully updated.'
      redirect_to(@customer)
    else
      render :action => "edit"
    end
  end

  def destroy
    @customer = Customer.find(params[:id])
    if @customer.projects.empty?
    @customer.destroy
    else
      flash[:error] = "Cannot remove customer with active projects"
    end
    redirect_to(customers_url)
  end
end
