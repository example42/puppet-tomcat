require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'tomcat::instance', :type => :define do

  let(:title) { 'tomcat_instance' }
  let(:node) { 'rspec.example42.com' }
  let(:params) { {
    :http_port => 8080,
    :control_port => 8480,
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


end

