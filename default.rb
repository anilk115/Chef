#
# Cookbook Name:: 
# Recipe:: default
#
#
#
# All rights reserved - Do Not Redistribute
#

include_recipe "java::oracle"

########################
# Deploy/Update CA Certs
########################

# Define CA Path
caPath = '/usr/lib/jvm/java/jre/lib/security'
keyTool = '/usr/lib/jvm/java/bin/keytool'

# Define Certs
@caFile = [
''
]

# Define Labels
@label = [
''
]

# Create/Update CA Certs
@caFile.zip(@label).each do |caFile, label|
	cookbook_file "#{caPath}/#{caFile}" do
      owner 'root'
      group 'root'
      mode "0755"
	  source "#{caFile}"
#	  notifies :run, 'execute[Import]', :immediately
      action :create
    end
	
	execute 'Import' do
	  command "#{keyTool} -import -trustcacerts -file #{caFile} -alias #{label} -keystore cacerts -storepass changeit -noprompt"
          returns [0, 1]
	  cwd "#{caPath}"
	  user 'root'
	  subscribes :run, "cookbook_file[#{caPath}/#{caFile}]", :immediately
	  action :nothing
	end
end	
