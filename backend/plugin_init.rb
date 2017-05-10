# omniauthCas/backend/plugin_init.rb

require 'aspace_logger'
require 'omniauth-cas'

include JSONModel

begin

  logger = ASpaceLogger.new($stderr);
  OmniAuth.config.logger = logger

  logger.info("omniauthCas/backend: AppConfig[:omniauthCas]='#{AppConfig[:omniauthCas]}'")####

  # Create from a list in the configuration a  set of admin users 
  users = AppConfig[:omniauthCas][:initialUsers] || [] 
  users.each do |username|
    next if User.find( :username => username )
    user = User.create_from_json(
      JSONModel(:user).from_hash(:username => username, :name => username),
      { :source => "local", :is_system_user => 1 }
    )
    
    RequestContext.open(:repo_id => Repository[:repo_code => Repository.GLOBAL].id ) do
     Group.find( :group_code => Group.ADMIN_GROUP_CODE  ).add_user( user )
    end 

 
    DBAuth.set_password(username, SecureRandom.hex)
    logger.info("Creating new admin user #{username}")  
  end

end
