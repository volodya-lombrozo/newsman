Gem::Specification.new do |spec|
  spec.name          = "newsman"
  spec.version       = "0.1.0"
  spec.authors       = ["Volodya Lombrozo"]
  spec.email         = ["volodya.lombrozo@gmail.com"]
  spec.summary       = "GitHub user weekly news"
  spec.description   = "A simple gem that gathers GitHub statistics and creates human-readable report"
  spec.homepage      = "https://github.com/volodya-lombrozo/newsman"
  spec.files         = Dir['lib/**/*.rb'] + Dir['bin/*']# Specify your main script here
  spec.executables   = ["newsman"] # Specify the executable name
  spec.require_paths = ["lib"]
  spec.license       = "MIT"
end

