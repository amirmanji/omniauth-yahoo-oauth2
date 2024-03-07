require File.expand_path(File.join('..', 'lib', 'omniauth', 'yahoo_oauth2', 'version'), __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Fabian Jäger']
  gem.email         = ['fabian@mailbutler.io']
  gem.description   = 'A Yahoo OAuth2 strategy for OmniAuth.'
  gem.summary       = gem.description
  gem.homepage      = 'https://github.com/Mailbutler/omniauth-yahoo-oauth2'
  gem.license       = 'MIT'

  gem.add_dependency 'omniauth-oauth2', '>= 1.5'

  gem.files         = `git ls-files`.split("\n")
  gem.name          = 'omniauth-yahoo-oauth2'
  gem.require_paths = ['lib']
  gem.version       = OmniAuth::YahooOauth2::VERSION
end
