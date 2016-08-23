require 'spec_helper'

describe 'shibboleth::idp' do
  let (:pre_condition) {
    "package { 'curl': } "
  }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'when passing no parameters' do
        it 'should fail' do
          expect { should compile }.to raise_error(/shibidp_keypass/)
        end
      end

      context 'when passing shibidp_version and shibidp_keepass' do
        let (:params) { {
          :shibidp_version => '3.2.1',
          :shibidp_keypass => 'abcd',
        } }

        it { should compile.with_all_deps }
      end

      context 'when passing an unsupported shibidp_version' do
        let (:params) { {
          :shibidp_version => '1.2.3',
          :shibidp_keypass => 'abcd',
        } }

        it 'should fail' do
          expect { should compile }.to raise_error(/only supports versions/)
        end
      end
    end
  end
end
