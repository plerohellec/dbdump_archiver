
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dbdump_archiver/version"

Gem::Specification.new do |spec|
  spec.name          = "dbdump_archiver"
  spec.version       = DbdumpArchiver::VERSION
  spec.authors       = ["Philippe Le Rohellec"]
  spec.email         = ["philippe@lerohellec.com"]

  spec.summary       = %q{Database dumps manager.}
  spec.description   = %q{Fetch database dumps and archive them.}
  spec.homepage      = "https://github.com/plerohellec/dbdump_archiver"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "awesome_print", "~> 1.0"
  spec.add_development_dependency "byebug", "~> 10.0"
end
