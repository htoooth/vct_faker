require 'rake/clean'

CLEAN.include('*.VCT')
CLEAN.include('*.part')

desc "test"
task :test do
     system 'ruby fake_vct.rb'
end

task :default => :test
