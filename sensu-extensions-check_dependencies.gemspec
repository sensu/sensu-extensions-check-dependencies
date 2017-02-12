# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "sensu-extensions-check_dependencies"
  spec.version       = "1.0.0"
  spec.authors       = ["Sensu Inc"]
  spec.email         = ["<support@sensu.io>"]

  spec.summary       = "Filter events when an event already exists for a defined check dependency"
  spec.description   = "Filter events when an event already exists for a defined check dependency"
  spec.homepage      = "https://github.com/sensu-extensions/sensu-extensions-check_dependencies"

  spec.files         = Dir.glob('{bin,lib}/**/*') + %w(LICENSE README.md CHANGELOG.md)
  spec.require_paths = ["lib"]

  spec.add_dependency "sensu-extension"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "sensu-logger"
  spec.add_development_dependency "sensu-settings"
end
