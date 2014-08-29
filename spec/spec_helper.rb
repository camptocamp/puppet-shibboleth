require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.before :each do
    if Gem::Version.new(`puppet --version`) >= Gem::Version.new('3.5')
      Puppet.settings[:strict_variables]=true
    end
  end
end
