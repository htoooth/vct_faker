require 'rake/clean'

CLEAN.include('*.VCT')

desc "generate task"
task :generate do
    (10..11).each do |i|
       system  "ruby main.rb #{i} TEST#{i}"
    end
end

task :default => :generate
