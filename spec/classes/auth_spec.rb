require 'spec_helper'

describe 'dovecot::auth', :type => 'class' do
  let :pre_condition do
    'include dovecot'
  end

  context "on a Debian OS" do
    let :facts do
      {
        :id             => 'root',
        :is_pe          => false,
        :osfamily       => 'Debian',
        :concat_basedir => '/dne',
        :path           => '/usr/sbin:/usr/bin:/sbin:/bin',
      }
    end

    it { should compile }

    it { should contain_file('/etc/dovecot/conf.d/10-auth.conf').with(
        'ensure' => 'present',
        'path'   => '/etc/dovecot/conf.d/10-auth.conf',
        'mode'   => '0644',
        'owner'  => 'root',
        'group'  => 'root',
        'notify' => 'Class[Dovecot::Service]',
      )
    }

    it {
      should contain_file('/etc/dovecot/conf.d/10-auth.conf') \
        .without_content(/^service auth \{$/)
    }

    context "with service_auth enabled" do
      let :params do
        {
          :service_auth => true,
        }
      end

      it {
        should contain_file('/etc/dovecot/conf.d/10-auth.conf') \
          .with_content(/^service auth \{$/)
      }

      it {
        should contain_file('/etc/dovecot/conf.d/10-auth.conf') \
          .with_content(/^   port = 12345$/)
      }
    end

    context "with service_auth enabled with different port" do
      let :params do
        {
          :service_auth      => true,
          :service_auth_port => '12341'
        }
      end

      it {
        should contain_file('/etc/dovecot/conf.d/10-auth.conf') \
          .with_content(/^service auth \{$/)
      }

      it {
        should contain_file('/etc/dovecot/conf.d/10-auth.conf') \
          .with_content(/^   port = 12341$/)
      }
    end

    context 'invalid service_auth setting' do
      let :params do
        {
          :service_auth => 'test'
        }
      end

      it do
        expect {
          should contain_file('/etc/dovecot/conf.d/10-auth.conf')
        }.to raise_error(Puppet::Error, /\"test\" is not a boolean/)
      end
    end
  end

  context "on an unknown OS" do
    let :facts do
      {
        :osfamily => 'Darwin'
      }
    end

    it {
      expect { should raise_error(Puppet::Error) }
    }
  end
end
