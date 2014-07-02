source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :development, :test do
  gem 'rake', '10.1.1'
  gem 'puppetlabs_spec_helper',  :require => false
  gem 'rspec-puppet', :github => 'rodjek/rspec-puppet', :branch => 'master'
  gem 'puppet-lint', '~> 0.3.2'
  gem 'rspec', '< 3.0.0'
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
