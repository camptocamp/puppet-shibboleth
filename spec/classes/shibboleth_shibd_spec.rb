require 'spec_helper'
describe 'shibboleth::shibd' do
  let (:pre_condition) {
    'Exec { path => "/foo" }'
  }

  context 'when using selinux' do
    let (:facts) { {
      :osfamily          => 'RedHat',
      :lsbmajdistrelease => '6',
      :selinux           => true,
    } }

    it { should compile.with_all_deps }
  end

  context 'when not using selinux' do
    let (:facts) { {
      :osfamily          => 'RedHat',
      :lsbmajdistrelease => '6',
      :selinux           => false,
    } }

    it { should compile.with_all_deps }
  end
end

