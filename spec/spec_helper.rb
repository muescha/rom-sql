# encoding: utf-8

require 'bundler'
Bundler.setup

if RUBY_ENGINE == 'rbx'
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require 'pg'
require 'rom-sql'
require 'logger'

LOGGER = Logger.new(File.open('./log/test.log', 'a'))

root = Pathname(__FILE__).dirname

Dir[root.join('shared/*.rb').to_s].each { |f| require f }

RSpec.configure do |config|
  config.before do
    @constants = Object.constants
  end

  config.after do
    [ROM::Relation, ROM::Mapper, ROM::Command].each { |klass| clear_descendants(klass) }

    added_constants = Object.constants - @constants
    added_constants.each { |name| Object.send(:remove_const, name) }
  end

  def clear_descendants(klass)
    klass.descendants.each { |d| clear_descendants(d) }
    klass.instance_variable_set('@descendants', [])
  end
end
