# frozen_string_literal: true

require_relative 'lib/frame_tree/version'

Gem::Specification.new do |spec|
  spec.name          = 'frame_tree'
  spec.version       = FrameTree::VERSION
  spec.summary       = 'In-memory Tree-like structure to store counters with rolling frame/window.'
  spec.homepage      = 'https://github.com/creadone/frame_tree'
  spec.license       = 'MIT'

  spec.author        = ['Sergey Fedorov']
  spec.email         = ['creadone@gmail.com']

  spec.files         = Dir['*.{md,txt}', '{lib}/**/*']
  spec.require_paths  = ['lib']

  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')
  spec.add_runtime_dependency 'terminal-table'
  spec.add_runtime_dependency 'msgpack'

  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake'
end
