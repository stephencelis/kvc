$: << File.dirname(__FILE__) + "/lib"
require "rubygems"
require "hoe"
require "active_record"
require "kvc"

Hoe.new("kvc", KVC::VERSION) do |p|
  p.developer("Stephen Celis", "stephen@stephencelis.com")
  p.remote_rdoc_dir = ''
end

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the KVC plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the kvc plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'KVC'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
