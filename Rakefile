require 'rake'
require 'rake/testtask'
require 'rake/minify'

Rake::Minify.new(:minify) do
  dir("js") do
    $LOAD_PATH.unshift(File.dirname(File.expand_path(__FILE__)) + '/lib')
    require "control-hub"
    add("js/controlHub-#{ControlHub::VERSION}.min.js", "controlHub.js") 
    add("js/controlHub.min.js", "controlHub.js") 
  end
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

task :default => [:test]
