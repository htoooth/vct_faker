require 'rake/clean'

CLEAN.include('*.VCT')
CLEAN.include('*.INDEX')
CLEAN.include('*.point')
CLEAN.include('*.line')
CLEAN.include('*.polygon')

desc "generate task"
task :generate do
    (100...101).each do |i|
       system  "ruby fake_vct.rb -s #{i} -t TEST#{i}"
    end
end

task :default => :generate
