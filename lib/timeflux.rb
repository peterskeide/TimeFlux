module TimeFlux
  
  class Config   
    def initialize
      @use_ldap = false 
    end        
    attr_accessor :use_ldap, :ldap_host, :ldap_base   
  end
      
  CONFIG = Config.new
  
  def self.configure
    raise "No block given" unless block_given?
    yield CONFIG
  end
                   
end