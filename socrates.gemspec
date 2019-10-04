lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "socrates/version"

Gem::Specification.new do |spec|
  spec.name     = "socrates"
  spec.version  = Socrates::VERSION
  spec.license  = "MIT"
  spec.authors  = ["Christian Nelson"]
  spec.email    = ["christian@carbonfive.com"]

  spec.summary  = "A micro-framework for building stateful conversational bots."
  spec.homepage = "https://github.com/carbonfive/socrates"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.4.0"

  spec.add_development_dependency "bundler", "~> 2.0.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.8"
  spec.add_development_dependency "rubocop", "= 0.75.0"
  spec.add_development_dependency "rubocop-performance", "= 1.4.1"
  spec.add_development_dependency "simplecov", "~> 0.16"
  spec.add_development_dependency "timecop", "~> 0.9"

  spec.add_dependency "activesupport", ">= 5.2"
  spec.add_dependency "async-websocket", ">= 0.8", "< 0.14"
  spec.add_dependency "hashie", ">= 3.6"
  spec.add_dependency "redis", ">= 4.1"
  spec.add_dependency "slack-ruby-client", ">= 0.14.4"
end
