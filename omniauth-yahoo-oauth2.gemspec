require File.expand_path(File.join('..', 'lib', 'omniauth', 'yahoo_oauth2', 'version'), __FILE__)

Gem::Specification.new do |gem|
  gem.add_runtime_dependency 'omniauth', '>= 1.1'
  gem.add_runtime_dependency 'omniauth-oauth2', '~> 1.1'
  gem.add_development_dependency 'bundler', '~> 1.0'

  gem.authors       = ['Amir Manji']
  gem.email         = ['amanji75@gmail.com']
  gem.description   = 'A Yahoo OAuth2 strategy for OmniAuth.'
  gem.summary       = gem.description
  gem.homepage      = 'https://github.com/amirmanji/omniauth-yahoo-oauth2'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split("\n")
  gem.name          = 'omniauth-yahoo-oauth2'
  gem.require_paths = ['lib']
  gem.version       = OmniAuth::YahooOauth2::VERSION
end
