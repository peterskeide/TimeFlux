
$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'user'

class UserTest < Test::Unit::TestCase
  
  context "A User instance" do

    setup do
      @user = User.find(:first)
      #puts "(setup user)"
      #@user ||= User.create!(:firstname => "HŒkon", :lastname => "Bommen", :login => "whatever", :email => 'me@myplace.com', :password => "secret")
    end

    teardown do
      User.find(:all).each { |u| u.destroy }
    end

    should "return its full name" do
      assert_equal 'HŒkon Bommen', @user.fullname
    end

    should "not save without a username" do
      user = User.new
      assert !user.save
    end

  end
end

