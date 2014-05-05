require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'tomcat::instance', :type => :define do

  let(:title) { 'tomcat_instance' }
  let(:node) { 'rspec.example42.com' }
  let(:params) { {
    :http_port => 8080,
    :control_port => 8480,
  } }
  let (:facts) { {
    :operatingsystem => 'CentOS',
    :osfamily        => 'RedHat',
  } }

  describe 'Test CentOS usage' do
    let (:facts) { {
      :operatingsystem => 'CentOS',
      :osfamily        => 'RedHat',
    } }

    it { should contain_file('instance_tomcat_defaults_tomcat_instance').with_path('/etc/sysconfig/tomcat6-tomcat_instance') }
  end

  describe 'Test RedHat usage' do
    let (:facts) { {
      :operatingsystem => 'RedHat',
      :osfamily        => 'RedHat',
    } }

    it { should contain_file('instance_tomcat_defaults_tomcat_instance').with_path('/etc/sysconfig/tomcat6-tomcat_instance') }
  end

  describe 'Test Debian usage' do
    let (:facts) { {
      :operatingsystem => 'Debian',
      :osfamily        => 'Debian',
    } }

    it { should contain_file('instance_tomcat_defaults_tomcat_instance').with_path('/etc/default/tomcat6-tomcat_instance') }
  end

  describe "Test apache vhost creation" do
    let(:params) { {
      :http_port           => 8080,
      :control_port        => 8480,
      :apache_vhost_create => true,
      :apache_vhost_server_name => 'tomcat.example42.com',
    } }

    describe "Simple" do
      it { should contain_file('/etc/httpd/conf.d/50-tomcat_instance.conf').with_content(/ProxyPass \/tomcat_instance http:\/\/localhost:8080\/tomcat_instance/) }
      it { should contain_file('/etc/httpd/conf.d/50-tomcat_instance.conf').with_content(/ProxyPassReverse \/tomcat_instance http:\/\/localhost:8080\/tomcat_instance/) }
    end

    describe "With manager enabled" do
      let(:params) { {
        :http_port                => 8080,
        :control_port             => 8480,
        :apache_vhost_create      => true,
        :apache_vhost_server_name => 'tomcat.example42.com',
        :manager                  => true,
      } }
      it { should contain_apache__vhost('tomcat_instance').with_server_name('tomcat.example42.com') }
      it { should contain_file('/etc/httpd/conf.d/50-tomcat_instance.conf').with_content(/ProxyPass \/tomcat_instance http:\/\/localhost:8080\/tomcat_instance/) }
      it { should contain_file('/etc/httpd/conf.d/50-tomcat_instance.conf').with_content(/ProxyPassReverse \/tomcat_instance http:\/\/localhost:8080\/tomcat_instance/) }
      it { should contain_file('/etc/httpd/conf.d/50-tomcat_instance.conf').with_content(/ProxyPassReverse \/manager http:\/\/localhost:8080\/manager/) }
      it { should contain_file('/etc/httpd/conf.d/50-tomcat_instance.conf').with_content(/ProxyPassReverse \/manager http:\/\/localhost:8080\/manager/) }
    end
  end


end

