require 'rake/clean'

CLEAN.include('*.VCT')
CLEAN.include('*.INDEX')
CLEAN.include('*.point')
CLEAN.include('*.line')
CLEAN.include('*.polygon')

desc "generate task"
task :generate do
    (500...501).each do |i|
       system  "ruby fake_vct.rb -s #{i} -t TEST#{i}"
    end
end

desc "generate 2000"
task :t2000 do 
    system 'ruby fake_vct.rb -s 2000 -t test1000 -e 100000 -f 10000000 -i 20 -a 200'
end

task :default => :generate
