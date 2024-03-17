Gem::Specification.new do |spec|
  spec.name          = "newsman"
  spec.version       = "0.1.1"
  spec.authors       = ["Volodya Lombrozo"]
  spec.email         = ["volodya.lombrozo@gmail.com"]
  spec.summary       = "GitHub user weekly news"
  spec.description   = "A simple gem that gathers GitHub statistics and creates human-readable report"
  spec.homepage      = "https://github.com/volodya-lombrozo/newsman"
  spec.files         = Dir.glob("{lib}/**/*") + Dir.glob("{bin}/**/*") + Dir.glob("{test,spec}/**/*") + ["README.md", "LICENSE.txt"]
  spec.executables   = ["newsman"] # Specify the executable name
  spec.require_paths = ["lib", "bin"]
  spec.license       = "MIT"

  spec.add_development_dependency "rspec", "~> 3.2"
end

