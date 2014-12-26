require 'spec_helper'

describe 'shibboleth::sp' do

  let(:pre_condition) {
    "
    file { '/etc/pki/rpm-gpg/': }
    service { 'httpd': }
    "
  }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should compile.with_all_deps }
    end
  end
end
