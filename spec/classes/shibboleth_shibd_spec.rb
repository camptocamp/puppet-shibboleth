require 'spec_helper'

describe 'shibboleth::shibd' do
  let(:pre_condition) {
    "
    package { 'shibboleth': }
    package { 'checkpolicy': }
    package { 'policycoreutils': }
    package { 'selinux-policy-devel': }
    "
  }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'when using selinux' do
        let (:facts) do
          facts.merge({
            :selinux => true,
          })
        end

        it { should compile.with_all_deps }
      end

      context 'when not using selinux' do
        let (:facts) do
          facts.merge({
            :selinux => false,
          })
        end

        it { should compile.with_all_deps }
      end
    end
  end
end
