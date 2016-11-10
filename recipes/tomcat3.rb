#
# Cookbook Name:: 
# Recipe:: tomcatB
#
# 
#
# All rights reserved - Do Not Redistribute
#

tcname = node["tomcat_zdd"]["tomcatB_name"]
tcver = node["tomcat_zdd"]["#{tcname}_version"]
tctarball = "apache-tomcat-#{tcver}.tar.gz"
tcurl = "http://archive.apache.org/dist/tomcat/tomcat-7/v#{tcver}/bin/#{tctarball}"
tctarget = node[tomcat_zdd"]["#{tcname}_target"]
tcuser = node["tomcat_zdd"]["user"]
tcgroup = node["tomcat_zdd"]["group"]

# Get the tomcat binary
remote_file "/opt/middleware/software/#{tctarball}" do
  source "#{tcurl}"
  owner "#{tcuser}"
  group "#{tcgroup}"
  mode "0644"
  action :create
  not_if {File.exists?("/opt/middleware/software/#{tctarball}")}
end

# Create base folder
directory "#{tctarget}/apache-tomcat-#{tcver}" do
  owner "#{tcuser}"
  group "#{tcgroup}"
  recursive true
  mode "0755"
  action :create
  not_if { ::File.directory?("#{tctarget}/apache-tomcat-#{tcver}") }
end

# Create the log folder
directory "/var/log/#{tcname}" do
  owner "#{tcuser}"
  group "#{tcgroup}"
  recursive true
  mode "0755"
  action :create
  not_if { ::File.directory?("/var/log/#{tcname}") }
end

# Extract
execute "tar" do
  user "#{tcuser}"
  group "#{tcgroup}"
  installation_dir = "#{tctarget}"
  cwd installation_dir
  command "tar zxf /opt/middleware/software/#{tctarball}"
  action :run
  not_if { ::File.directory?("#{tctarget}/apache-tomcat-#{tcver}/bin") }
end

# Set the symlink
link "#{tctarget}/tomcat" do
  to "apache-tomcat-#{tcver}"
  link_type :symbolic
  owner "#{tcuser}"
  group "#{tcgroup}"
  not_if {File.exists?("#{tctarget}/tomcat")}
end

# Create home Directory link
link "/home/tomcat/#{tcname}" do
  to "#{tctarget}/tomcat"
  link_type :symbolic
  owner "#{tcuser}"
  group "#{tcgroup}"
  not_if {File.exists?("/home/tomcat/#{tcname}")}
end

# Change the log directory
directory "#{tctarget}/apache-tomcat-#{tcver}/logs" do
  action :delete
  not_if { File.symlink?("#{tctarget}/apache-tomcat-#{tcver}/logs") }
end

# create the symlink to /var/log/tomcatB
link "#{tctarget}/tomcat/logs" do
  to "/var/log/#{tcname}"
  link_type :symbolic
  owner "#{tcuser}"
  group "#{tcgroup}"
  not_if {File.exists?("#{tctarget}/tomcat/logs")}
end

# Add the logrotate for catalina.out
template "#{tcname}_logrotate" do
  path "/etc/logrotate.d/#{tcname}"
  source "#{tcname}_logrotate.erb"
  owner "root"
  group "root"
  mode "0755"
end

# Add the init-script
service "#{tcname}" do
  supports :restart => true, :start => true, :stop => true, :status => true, :kill => true
  action :nothing
end

template "#{tcname}" do
  path "/etc/init.d/#{tcname}"
  source "#{tcname}_init.erb"
  owner "root"
  group "root"
  mode "0755"
end

# Config from template
template "#{tctarget}/tomcat/conf/server.xml" do
  source "#{tcname}_server.xml.erb"
  owner "#{tcuser}"
  group "#{tcgroup}"
  mode "0644"
end

template "#{tctarget}/tomcat/bin/setenv.sh" do
  source "#{tcname}_setenv.sh.erb"
  owner "#{tcuser}"
  group "#{tcgroup}"
  mode "0755"
end

directory "/opt/middleware/tomcat_config/#{tcname}" do
  owner "#{tcuser}"
  group "#{tcgroup}"
  recursive true
  mode "0755"
  action :create
  not_if { ::File.directory?("/opt/middleware/tomcat_config/#{tcname}") }
end

template "/opt/middleware/tomcat_config/#{tcname}/middleware_variables.conf" do
  source "#{tcname}_middleware_variables.conf.erb"
  owner "#{tcuser}"
  group "#{tcgroup}"
  mode "0700"
  not_if {File.exists?("/opt/middleware/tomcat_config/#{tcname}/middleware_variables.conf")}
end

template "/opt/middleware/tomcat_config/#{tcname}/jvm_options.conf" do
  source "#{tcname}_jvm_options.conf.erb"
  owner "#{tcuser}"
  group "#{tcgroup}"
  mode "0700"
  not_if {File.exists?("/opt/middleware/tomcat_config/#{tcname}/jvm_options.conf")}
end

template "/opt/middleware/tomcat_config/#{tcname}/monitoring_options.conf-disabled" do
  source "#{tcname}_monitoring_options.conf.erb"
  owner "#{tcuser}"
  group "#{tcgroup}"
  mode "0700"
  not_if {File.exists?("/opt/middleware/tomcat_config/#{tcname}/monitoring_options.conf-disabled")}
end

template "/opt/middleware/tomcat_config/#{tcname}/application_options.conf" do
  source "#{tcname}_application_options.conf.erb"
  owner "#{tcuser}"
  group "#{tcgroup}"
  mode "0700"
  not_if {File.exists?("/opt/middleware/tomcat_config/#{tcname}/application_options.conf")}
end

template "/opt/middleware/tomcat_config/#{tcname}/jmxremote.access" do
  source "jmxremote.access.erb"
  owner "#{tcuser}"
  group "#{tcgroup}"
  mode "0700"
  not_if {File.exists?("/opt/middleware/tomcat_config/#{tcname}/jmxremote.access")}
end

template "/opt/middleware/tomcat_config/#{tcname}/jmxremote.password" do
  source "jmxremote.password.erb"
  owner "#{tcuser}"
  group "#{tcgroup}"
  mode "0700"
  not_if {File.exists?("/opt/middleware/tomcat_config/#{tcname}/jmxremote.password")}
end

service "#{tcname}" do
  action [:enable, :start]
end
