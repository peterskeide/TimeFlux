module TimeFlux
    
  # TimeFlux supports both database and ldap based authentication (default is database). To switch to LDAP, 
  # add these lines to the configuration block in intall_path/config/initializers/timeflux_config.rb:
  #
  # TimeFlux::Configuration[:authentication_method]= :ldap
  # TimeFlux::Configuration[:authentication_options]= {:host => 'your.host.here', :base => 'ou=people,dc=foobar,dc=com'} 
  #
  # Change :host and :base to suit your needs. If you have a user with username/login 'bob', the options
  # will be compiled to e.g 'uid=bob,ou=people,dc=foobar,dc=com'
  Configuration = {:authentication_method => :database}
  
  # Container for modules that implement custom configurable behavior for various TimeFlux classes. 
  # These modules should implement the 'included' method to add configurable behavior to their target classes.
  module ConfigurableBehavior
    
    # Enables support for configuring authentication backed by database or ldap in the User model.
    module UserModel
      def self.included(klass)
        raise "Can only be included by User class" unless klass.name == 'User'
        case TimeFlux::Configuration[:authentication_method]
        when :database
          User.acts_as_authentic
        when :ldap
          host = TimeFlux::Configuration[:authentication_options][:host]
          base = TimeFlux::Configuration[:authentication_options][:base]
          User.class_eval <<-EOF
          acts_as_authentic { |c| c.validate_password_field = false }

          def valid_ldap_credentials?(password_plaintext)
            ldap = Net::LDAP.new
            ldap.host = "#{host}"
            auth_str = "uid=" + self.login + ",#{base}"
            ldap.auth auth_str, password_plaintext
            ldap.bind # will return false if authentication is NOT successful
          end

          private :valid_ldap_credentials?
          EOF
        end
      end
    end
    
    # Enables support for configuring authentication backed by database or ldap in the UserSession model.
    module UserSessionModel
      def self.included(klass)
        raise "Can only be included by UserSession class" unless klass.name == 'UserSession'
        UserSession.verify_password_method(:valid_ldap_credentials?) if TimeFlux::Configuration[:authentication_method] == :ldap
      end
    end
    
  end
                
end