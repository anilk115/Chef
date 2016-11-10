#
# Cookbook Name:: xyz
# Recipe:: default
#
# Copyright (C) 2015 anil 
#
# All rights reserved - Do Not Redistribute
#

# include java to make sure it is there
include_recipe "java"

# Get the tomcat user and group from the attributes file
tcuser = node["tomcat_base"]["user"]
tcgroup = node["tomcat_base"]["group"]
tcverA = node["tomcat_base"]["tomcatA_version"]
tcverB = node["tomcat_base"]["tomcatB_version"]
tcmajverA = node["tomcat_base"]["tomcatA_major_version"]
tcmajverB = node["tomcat_base"]["tomcatB_major_version"]
tcurlA = "http://archive.apache.org/dist/tomcat/tomcat-#{tcmajverA}/v#{tcverA}/bin/apache-tomcat-#{tcverA}.tar.gz"
tcurlB = "http://archive.apache.org/dist/tomcat/tomcat-#{tcmajverB}/v#{tcverB}/bin/apache-tomcat-#{tcverB}.tar.gz"


# Create the tomcat group if it does not exist
group tcgroup do
  action :create
  gid 25985
  not_if "grep #{tcgroup} /etc/group"
end

# Create the tomcat user if it does not exist
user tcuser do
  supports :manage_home => true
  comment ""
  uid 35985
  gid 25985
  home "/home/tomcat"
  shell "/bin/bash"
  password ""
  not_if "grep #{tcuser} /etc/passwd"
end


# Now we need to create all the directories that we will need
%w[ /opt/middleware
    /opt/middleware/software
    /opt/middleware/software/tomcatA
    /opt/middleware/software/tomcatB
    /opt/middleware/Tools
    /opt/middleware/application
    /opt/middleware/application/tomcatA
    /opt/middleware/application/tomcatA/config
    /opt/middleware/application/tomcatA/lib
    /opt/middleware/application/tomcatB
    /opt/middleware/application/tomcatB/config
    /opt/middleware/application/tomcatB/lib
    /usr/share/tomcatA
    /usr/share/tomcatB
    /var/log/tomcatA
    /var/log/tomcatB
    /opt/middleware/tomcatA
    /opt/middleware/tomcatA/common
    /opt/middleware/tomcatB
    /opt/middleware/tomcatB/common
    ].each do |path|
      directory path do
      owner tcuser
      group tcgroup
      recursive true
      mode "0755"
      action :create
   end
end

template "/opt/middleware/Tools/pids.pl" do
  source "pids.pl.erb"
  owner "#{tcuser}"
  group "#{tcgroup}"
  mode "0755"
end

template "/opt/middleware/Tools/bounce.pl" do
  source "bounce.pl.erb"
  owner "#{tcuser}"
  group "#{tcgroup}"
  mode "0755"
end

template "/opt/middleware/Tools/checkstatus.sh" do
  source "checkstatus.sh.erb"
  owner "#{tcuser}"
  group "#{tcgroup}"
  mode "0755"
end

# Add tomcat conf so tomcat can restart apache
template "/etc/sudoers.d/apache_tomcat_conf" do
  source "tomcat_apache_sudo_conf.erb"
  owner "root"
  group "root"
  mode "0440"
  not_if {File.exists?("/etc/sudoers.d/apache_tomcat_conf")}
end

template '/etc/security/limits.d/80-tomcat.conf' do
  source '80-tomcat.conf.erb'
  owner 'root'
  group 'root'
  mode '0600'
end


# Now we will do the common things that are needed for each version (small/medium/large)
# Download the Tarball for tomcatA
remote_file "/opt/middleware/software/tomcatA/apache-tomcat-#{tcverA}.tar.gz" do
  source "#{tcurlA}"
  owner "#{tcuser}"
  group "#{tcgroup}"
  mode "0644"
  action :create
  not_if {File.exists?("/opt/middleware/software/tomcatA/apache-tomcat-#{tcverA}.tar.gz")}
end

# Download the Tarball for tomcatB
remote_file "/opt/middleware/software/tomcatB/apache-tomcat-#{tcverB}.tar.gz" do
  source "#{tcurlB}"
  owner "#{tcuser}"
  group "#{tcgroup}"
  mode "0644"
  action :create
  not_if {File.exists?("/opt/middleware/software/tomcatB/apache-tomcat-#{tcverB}.tar.gz")}
end

# Extract tomcatA tar ball
execute "tar" do
  user "#{tcuser}"
  group "#{tcgroup}"
  installation_dir = "/usr/share/tomcatA"
  cwd installation_dir
  command "tar zxf /opt/middleware/software/tomcatA/apache-tomcat-#{tcverA}.tar.gz"
  action :run
  not_if { ::File.directory?("/usr/share/tomcatA/apache-tomcat-#{tcverA}/bin") }
end

# Extract tomcatB tar ball
execute "tar" do
  user "#{tcuser}"
  group "#{tcgroup}"
  installation_dir = "/usr/share/tomcatB"
  cwd installation_dir
  command "tar zxf /opt/middleware/software/tomcatB/apache-tomcat-#{tcverB}.tar.gz"
  action :run
  not_if { ::File.directory?("/usr/share/tomcatB/apache-tomcat-#{tcverB}/bin") }
end

# Set the symlink for tomcatA
link "/usr/share/tomcatA/tomcat" do
  to "/usr/share/tomcatA/apache-tomcat-#{tcverA}"
  link_type :symbolic
  owner "#{tcuser}"
  group "#{tcgroup}"
end

# Set the symlink for tomcatB
link "/usr/share/tomcatB/tomcat" do
  to "/usr/share/tomcatB/apache-tomcat-#{tcverB}"
  link_type :symbolic
  owner "#{tcuser}"
  group "#{tcgroup}"
end

node.set['middleware'][:type] = 'tomcat'
tag('tomcat')
