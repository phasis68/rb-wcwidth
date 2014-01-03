Gem::Specification.new {|g|
    g.name          = 'rb-wcwidth'
    g.version       = '1.0.0'
    g.author        = 'Park Heesob'
    g.email         = 'phasis@gmail.com'
    g.homepage      = 'http://github.com/phasis68/rb-wcwidth'
    g.platform      = Gem::Platform::RUBY
    g.description   = 'ruby implementation of wcwidth'
    g.summary       = g.description.dup
    g.files         = Dir.glob('lib/**/*')
    g.require_path  = 'lib'
    g.executables   = [ ]
    g.has_rdoc      = false
}
