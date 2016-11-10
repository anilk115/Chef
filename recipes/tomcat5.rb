#
# Cookbook Name:: 
# Recipe:: small
#
# 
#
# All rights reserved - Do Not Redistribute
#
# This recipe will create one instance of each tomcatA and tomcatB

# Set up all the common stuff
include_recipe ""


tcuser = node[""]["user"]
tcgroup = node[""]["group"]

# create the instances
# create the directories that we will need
%w[ /opt/middleware/tomcatA/tomcatA1
    /opt/middleware/tomcatA/tomcatA1/bin
    /opt/middleware/tomcatA/tomcatA1/conf
    /opt/middleware/tomcatA/tomcatA1/webapps
    /opt/middleware/tomcatA/tomcatA1/temp
    /opt/middleware/tomcatA/tomcatA1/work
    /opt/middleware/tomcatA/tomcatA1/lib
    /opt/middleware/tomcatB/tomcatB1
    /opt/middleware/tomcatB/tomcatB1/bin
    /opt/middleware/tomcatB/tomcatB1/conf
    /opt/middleware/tomcatB/tomcatB1/webapps
    /opt/middleware/tomcatB/tomcatB1/temp
    /opt/middleware/tomcatB/tomcatB1/work
    /opt/middleware/tomcatB/tomcatB1/lib
    /var/log/tomcatA/tomcatA1
    /var/log/tomcatB/tomcatB1
    ].each do |path|
      directory path do
      owner tcuser
      group tcgroup
      recursive true
      mode "0755"
      action :create
   end
end

template "/home/tomcat/.bash_profile" do
  source "small_bash_profile.sh.erb"
  owner "#{tcuser}"
  group "#{tcgroup}"
  mode "0744"
end

for bininstall in [ "A", "B" ] do
  template "/opt/middleware/tomcat#{bininstall}/common/middleware_variables.conf" do
    source "middleware_variables.conf.erb"
    owner "#{tcuser}"
    group "#{tcgroup}"
    mode "0744"
    not_if {File.exists?("/opt/middleware/tomcat#{bininstall}/common/middleware_variables.conf")}
  end

  template "/opt/middleware/tomcat#{bininstall}/common/jvm_options.conf" do
    source "jvm_options.conf.erb"
    owner "#{tcuser}"
    group "#{tcgroup}"
    mode "0744"
    not_if {File.exists?("/opt/middleware/tomcat#{bininstall}/common/jvm_options.conf")}
  end

  template "/opt/middleware/tomcat#{bininstall}/common/application_options.conf" do
    source "application_options.conf_#{bininstall}.erb"
    owner "#{tcuser}"
    group "#{tcgroup}"
    mode "0744"
    not_if {File.exists?("/opt/middleware/tomcat#{bininstall}/common/application_options.conf")}
  end

  template "/opt/middleware/tomcat#{bininstall}/common/jmxremote.access" do
    source "jmxremote.access.erb"
    owner "#{tcuser}"
    group "#{tcgroup}"
    mode "0744"
    not_if {File.exists?("/opt/middleware/tomcat#{bininstall}/common/jmxremote.access")}
  end

  template "/opt/middleware/tomcat#{bininstall}/common/jmxremote.password" do
    source "jmxremote.password.erb"
    owner "#{tcuser}"
    group "#{tcgroup}"
    mode "0744"
    not_if {File.exists?("/opt/middleware/tomcat#{bininstall}/common/jmxremote.password")}
  end

  link "/opt/middleware/tomcat#{bininstall}/tomcat#{bininstall}1/logs" do
    to "/var/log/tomcat#{bininstall}/tomcat#{bininstall}1"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/opt/middleware/tomcat#{bininstall}/tomcat#{bininstall}1/logs")}
  end

  template "tomcat#{bininstall}1" do
    path "/etc/init.d/tomcat#{bininstall}1"
    source "tomcat#{bininstall}1_init.erb"
    owner "root"
    group "root"
    mode "0755"
  end

  template "/opt/middleware/tomcat#{bininstall}/tomcat#{bininstall}1/conf/server.xml" do
    source "tomcat#{bininstall}1_server.xml.erb"
    owner "#{tcuser}"
    group "#{tcgroup}"
    mode "0644"
  end

   template "/opt/middleware/tomcat#{bininstall}/tomcat#{bininstall}1/conf/datasource.xml" do
    source "datasource.xml.erb"
    owner "#{tcuser}"
    group "#{tcgroup}"
    mode "0644"
    not_if {File.exists?("/opt/middleware/tomcat#{bininstall}/tomcat#{bininstall}1/conf/datasource.xml")}
  end

  link "/opt/middleware/tomcat#{bininstall}/tomcat#{bininstall}1/conf/catalina.policy" do
    to "/usr/share/tomcat#{bininstall}/tomcat/conf/catalina.policy"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/opt/middleware/tomcat#{bininstall}/tomcat#{bininstall}1/conf/catalina.policy")}
  end

  link "/opt/middleware/tomcat#{bininstall}/tomcat#{bininstall}1/conf/catalina.properties" do
    to "/usr/share/tomcat#{bininstall}/tomcat/conf/catalina.properties"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/opt/middleware/tomcat#{bininstall}/tomcat#{bininstall}1/conf/catalina.properties")}
  end

  link "/opt/middleware/tomcat#{bininstall}/tomcat#{bininstall}1/conf/context.xml" do
    to "/usr/share/tomcat#{bininstall}/tomcat/conf/context.xml"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/opt/middleware/tomcat#{bininstall}/tomcat#{bininstall}1/conf/context.xml")}
  end

  link "/opt/middleware/tomcat#{bininstall}/tomcat#{bininstall}1/conf/logging.properties" do
    to "/usr/share/tomcat#{bininstall}/tomcat/conf/logging.properties"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/opt/middleware/tomcat#{bininstall}/tomcat#{bininstall}1/conf/logging.properties")}
  end

  link "/opt/middleware/tomcat#{bininstall}/tomcat#{bininstall}1/conf/tomcat-users.xml" do
    to "/usr/share/tomcat#{bininstall}/tomcat/conf/tomcat-users.xml"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/opt/middleware/tomcat#{bininstall}/tomcat#{bininstall}1/conf/tomcat-users.xml")}
  end

  link "/opt/middleware/tomcat#{bininstall}/tomcat#{bininstall}1/conf/web.xml" do
    to "/usr/share/tomcat#{bininstall}/tomcat/conf/web.xml"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/opt/middleware/tomcat#{bininstall}/tomcat#{bininstall}1/conf/web.xml")}
  end

  template "/opt/middleware/tomcat#{bininstall}/tomcat#{bininstall}1/bin/setenv.sh" do
    source "tomcat#{bininstall}1_setenv.sh.erb"
    owner "#{tcuser}"
    group "#{tcgroup}"
    mode "0755"
  end

  link "/home/tomcat/tomcat#{bininstall}1" do
    to "/opt/middleware/tomcat#{bininstall}/tomcat#{bininstall}1"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/home/tomcat/tomcat#{bininstall}1")}
  end

  template '/etc/logrotate.d/tomcat' do
    source 'logrotate_tomcat_small.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
  end

  service "tomcat#{bininstall}1" do
    supports :restart => true, :start => true, :stop => true, :status => true, :kill => true
    action :nothing
  end
end

node.set['middleware'][:size] = 'small'
