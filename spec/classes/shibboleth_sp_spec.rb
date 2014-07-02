require 'spec_helper'
describe 'shibboleth::sp' do
  let (:facts) { {
    :osfamily          => 'RedHat',
    :lsbmajdistrelease => '6',
    :architecture      => 'i386',
  } }

  it { should compile.with_all_deps }
end
