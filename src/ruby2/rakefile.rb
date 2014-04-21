require 'rake/clean'

CLEAN.include('*.VCT')
CLEAN.include('*.part')
CLEAN.include('*.point')
CLEAN.include('*.line')
CLEAN.include('*.polygon')

desc "test"
task :test do
     system 'ruby fake_vct.rb'
end

task :default => :test
