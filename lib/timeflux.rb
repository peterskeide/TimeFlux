=begin
Module for configuring special aspects of TimeFlux, such as authentication mechanism.

TimeFlux supports both databased and ldap based authentication (default is database).
Uncomment the code in {install-path}/config/initializers/timeflux_config.rb to switch to LDAP:

TimeFlux.configuration do |config|
  config.authenticate_with :ldap, {:host => 'your.host.here', :base => 'ou=people,dc=foobar,dc=com', :filter => 'uid='}
end

Change :host, :base and :filter to suit your needs. If you have a user with username/login 'bob', 
the base and filter options will be compiled to e.g 'uid=bob,ou=people,dc=foobar,dc=com'
=end
module TimeFlux
          
  class TimeFluxConfig
    
    def initialize
      @valid_auth_methods = [:database, :ldap]
      @authentication_method = :database
      @authentication_options = {}
    end
    
    attr_reader :authentication_method, :authentication_options
    
    def authenticate_with(method, options = {})
      raise ArgumentError, "Unknown authentication method (#{method})" unless @valid_auth_methods.include? method
      @authentication_method = method
      @authentication_options = options
    end
    
    def for_User
      case @authentication_method
      when :database
        User.acts_as_authentic
      when :ldap
        User.class_eval <<-EOF
        acts_as_authentic { |c| c.validate_password_field = false }

        def valid_ldap_credentials?(password_plaintext)
          ldap = Net::LDAP.new
          ldap.host = "#{@authentication_options[:host]}"
          auth_str = "#{@authentication_options[:filter]}" + self.login + ",#{@authentication_options[:base]}"
          ldap.auth auth_str, password_plaintext
          ldap.bind # will return false if authentication is NOT successful
        end

        private :valid_ldap_credentials?
        EOF
      end
    end
    
    def for_UserSession
      UserSession.verify_password_method(:valid_ldap_credentials?) if @authentication_method == :ldap
    end
    
  end
  
  Config = TimeFluxConfig.new
  
  def self.configuration
    raise "No block given" unless block_given?
    yield Config
  end
  
  def self.configure(klass)
    case klass.name
    when 'User'
      Config.for_User
    when 'UserSession'
      Config.for_UserSession
    end
  end
                
end