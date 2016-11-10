#
# Cookbook Name:: 
# Recipe:: medium
#
# 
#
# All rights reserved - Do Not Redistribute
#
# This recipe will create two instances of each tomcatA and tomcatB

# Set up all the common stuff
include_recipe ""

tcuser = node[""]["user"]
tcgroup = node[""]["group"]

%w[ /opt/middleware/tomcatA/tomcatA1
    /opt/middleware/tomcatA/tomcatA1/bin
    /opt/middleware/tomcatA/tomcatA1/conf
    /opt/middleware/tomcatA/tomcatA1/webapps
    /opt/middleware/tomcatA/tomcatA1/temp
    /opt/middleware/tomcatA/tomcatA1/work
    /opt/middleware/tomcatA/tomcatA1/lib
    /opt/middleware/tomcatA/tomcatA2
    /opt/middleware/tomcatA/tomcatA2/bin
    /opt/middleware/tomcatA/tomcatA2/conf
    /opt/middleware/tomcatA/tomcatA2/webapps
    /opt/middleware/tomcatA/tomcatA2/temp
    /opt/middleware/tomcatA/tomcatA2/work
    /opt/middleware/tomcatA/tomcatA2/lib
    /opt/middleware/tomcatB/tomcatB1
    /opt/middleware/tomcatB/tomcatB1/bin
    /opt/middleware/tomcatB/tomcatB1/conf
    /opt/middleware/tomcatB/tomcatB1/webapps
    /opt/middleware/tomcatB/tomcatB1/temp
    /opt/middleware/tomcatB/tomcatB1/work
    /opt/middleware/tomcatB/tomcatB1/lib
    /opt/middleware/tomcatB/tomcatB2
    /opt/middleware/tomcatB/tomcatB2/bin
    /opt/middleware/tomcatB/tomcatB2/conf
    /opt/middleware/tomcatB/tomcatB2/webapps
    /opt/middleware/tomcatB/tomcatB2/temp
    /opt/middleware/tomcatB/tomcatB2/work
    /opt/middleware/tomcatB/tomcatB2/lib
    /var/log/tomcatA/tomcatA1
    /var/log/tomcatA/tomcatA2
    /var/log/tomcatB/tomcatB1
    /var/log/tomcatB/tomcatB2
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
  source "medium_bash_profile.sh.erb"
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
end


# create the A instances
for instance in [ "A1", "A2" ] do

  link "/opt/middleware/tomcatA/tomcat#{instance}/logs" do
    to "/var/log/tomcatA/tomcat#{instance}"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/opt/middleware/tomcatA/tomcat#{instance}/logs")}
  end

  template "tomcat#{instance}" do
    path "/etc/init.d/tomcat#{instance}"
    source "tomcat#{instance}_init.erb"
    owner "root"
    group "root"
    mode "0755"
  end

  template "/opt/middleware/tomcatA/tomcat#{instance}/conf/server.xml" do
    source "tomcat#{instance}_server.xml.erb"
    owner "#{tcuser}"
    group "#{tcgroup}"
    mode "0644"
  end

   template "/opt/middleware/tomcatA/tomcat#{instance}/conf/datasource.xml" do
    source "datasource.xml.erb"
    owner "#{tcuser}"
    group "#{tcgroup}"
    mode "0644"
    not_if {File.exists?("/opt/middleware/tomcatA/tomcat#{instance}/conf/datasource.xml")}
  end

  link "/opt/middleware/tomcatA/tomcat#{instance}/conf/catalina.policy" do
    to "/usr/share/tomcatA/tomcat/conf/catalina.policy"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/opt/middleware/tomcatA/tomcat#{instance}/conf/catalina.policy")}
  end

  link "/opt/middleware/tomcatA/tomcat#{instance}/conf/catalina.properties" do
    to "/usr/share/tomcatA/tomcat/conf/catalina.properties"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/opt/middleware/tomcatA/tomcat#{instance}/conf/catalina.properties")}
  end

  link "/opt/middleware/tomcatA/tomcat#{instance}/conf/context.xml" do
    to "/usr/share/tomcatA/tomcat/conf/context.xml"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/opt/middleware/tomcatA/tomcat#{instance}/conf/context.xml")}
  end

  link "/opt/middleware/tomcatA/tomcat#{instance}/conf/logging.properties" do
    to "/usr/share/tomcatA/tomcat/conf/logging.properties"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/opt/middleware/tomcatA/tomcat#{instance}/conf/logging.properties")}
  end

  link "/opt/middleware/tomcatA/tomcat#{instance}/conf/tomcat-users.xml" do
    to "/usr/share/tomcatA/tomcat/conf/tomcat-users.xml"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/opt/middleware/tomcatA/tomcat#{instance}/conf/tomcat-users.xml")}
  end

  link "/opt/middleware/tomcatA/tomcat#{instance}/conf/web.xml" do
    to "/usr/share/tomcatA/tomcat/conf/web.xml"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/opt/middleware/tomcatA/tomcat#{instance}/conf/web.xml")}
  end

  template "/opt/middleware/tomcatA/tomcat#{instance}/bin/setenv.sh" do
    source "tomcat#{instance}_setenv.sh.erb"
    owner "#{tcuser}"
    group "#{tcgroup}"
    mode "0755"
  end

  link "/home/tomcat/tomcat#{instance}" do
    to "/opt/middleware/tomcatA/tomcat#{instance}"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/home/tomcat/tomcat#{instance}")}
  end

  service "tomcat#{instance}" do
    supports :restart => true, :start => true, :stop => true, :status => true, :kill => true
    action :nothing
  end
end

# create the B instances
for instance in [ "B1", "B2" ] do
  link "/opt/middleware/tomcatB/tomcat#{instance}/logs" do
    to "/var/log/tomcatB/tomcat#{instance}"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/opt/middleware/tomcatB/tomcat#{instance}/logs")}
  end

  template "tomcat#{instance}" do
    path "/etc/init.d/tomcat#{instance}"
    source "tomcat#{instance}_init.erb"
    owner "root"
    group "root"
    mode "0755"
  end

  template "/opt/middleware/tomcatB/tomcat#{instance}/conf/server.xml" do
    source "tomcat#{instance}_server.xml.erb"
    owner "#{tcuser}"
    group "#{tcgroup}"
    mode "0644"
  end

   template "/opt/middleware/tomcatB/tomcat#{instance}/conf/datasource.xml" do
    source "datasource.xml.erb"
    owner "#{tcuser}"
    group "#{tcgroup}"
    mode "0644"
    not_if {File.exists?("/opt/middleware/tomcatB/tomcat#{instance}/conf/datasource.xml")}
  end

  link "/opt/middleware/tomcatB/tomcat#{instance}/conf/catalina.policy" do
    to "/usr/share/tomcatB/tomcat/conf/catalina.policy"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/opt/middleware/tomcatB/tomcat#{instance}/conf/catalina.policy")}
  end

  link "/opt/middleware/tomcatB/tomcat#{instance}/conf/catalina.properties" do
    to "/usr/share/tomcatB/tomcat/conf/catalina.properties"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/opt/middleware/tomcatB/tomcat#{instance}/conf/catalina.properties")}
  end

  link "/opt/middleware/tomcatB/tomcat#{instance}/conf/context.xml" do
    to "/usr/share/tomcatB/tomcat/conf/context.xml"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/opt/middleware/tomcatB/tomcat#{instance}/conf/context.xml")}
  end

  link "/opt/middleware/tomcatB/tomcat#{instance}/conf/vlogging.properties" do
    to "/usr/share/tomcatB/tomcat/conf/logging.properties"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/opt/middleware/tomcatB/tomcat#{instance}/conf/logging.properties")}
  end

  link "/opt/middleware/tomcatB/tomcat#{instance}/conf/tomcat-users.xml" do
    to "/usr/share/tomcatB/tomcat/conf/tomcat-users.xml"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/opt/middleware/tomcatB/tomcat#{instance}/conf/tomcat-users.xml")}
  end

  link "/opt/middleware/tomcatB/tomcat#{instance}/conf/web.xml" do
    to "/usr/share/tomcatB/tomcat/conf/web.xml"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/opt/middleware/tomcatB/tomcat#{instance}/conf/web.xml")}
  end

  template "/opt/middleware/tomcatB/tomcat#{instance}/bin/setenv.sh" do
    source "tomcat#{instance}_setenv.sh.erb"
    owner "#{tcuser}"
    group "#{tcgroup}"
    mode "0755"
  end

  link "/home/tomcat/tomcat#{instance}" do
    to "/opt/middleware/tomcatB/tomcat#{instance}"
    link_type :symbolic
    owner "#{tcuser}"
    group "#{tcgroup}"
    not_if {File.exists?("/home/tomcat/tomcat#{instance}")}
  end

  template '/etc/logrotate.d/tomcat' do
    source 'logrotate_tomcat_medium.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
  end

  service "tomcat#{instance}" do
    supports :restart => true, :start => true, :stop => true, :status => true, :kill => true
    action :nothing
  end
end

node.set['middleware'][:size] = 'medium'
