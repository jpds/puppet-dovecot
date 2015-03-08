require 'spec_helper'

describe 'dovecot::ssl', :type => 'class' do
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

    it { should contain_file('/etc/dovecot/conf.d/10-ssl.conf').with(
        'ensure' => 'present',
        'path'   => '/etc/dovecot/conf.d/10-ssl.conf',
        'mode'   => '0644',
        'owner'  => 'root',
        'group'  => 'root',
        'notify' => 'Class[Dovecot::Service]',
      )
    }

    it {
      should contain_file('/etc/dovecot/conf.d/10-ssl.conf') \
        .with_content(/^ssl = no$/)
    }

    context "with enable_ssl" do
      let :params do
        {
          :enable_ssl => true,
        }
      end

      it {
        should contain_file('/etc/dovecot/conf.d/10-ssl.conf') \
          .with_content(/^ssl = yes$/)
      }
    end

    context 'invalid enable_ssl setting' do
      let :params do
        {
          :enable_ssl => 'test'
        }
      end

      it do
        expect {
          should contain_file('/etc/dovecot/conf.d/10-ssl.conf')
        }.to raise_error(Puppet::Error, /\"test\" is not a boolean/)
      end
    end

    context "with ssl_protocols set" do
      let :params do
        {
          :ssl_protocols => '!SSLv2 !SSLv3',
        }
      end

      it {
        should contain_file('/etc/dovecot/conf.d/10-ssl.conf') \
          .with_content(/^ssl_protocols = !SSLv2 !SSLv3$/)
      }
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
