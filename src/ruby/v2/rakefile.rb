require 'rake/clean'

CLEAN.include('*.VCT')
CLEAN.include('*.part')
CLEAN.include('*.index')

def os
    @os ||= (
      host_os = RbConfig::CONFIG['host_os']
      case host_os
      when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
        :windows
      when /darwin|mac os/
        :macosx
      when /linux/
        :linux
      when /solaris|bsd/
        :unix
      else
        raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
      end
    )
end

def merge_file(name)
    cat = "cat #{name}.head.part " + 
              "#{name}.featurecode.part " + 
              "#{name}.table.part " +
              "#{name}.point.geometry.part " + 
              "#{name}.line.geometry.part " + 
              "#{name}.polygon.geometry.part " +
              "#{name}.point.attribute.part " +
              "#{name}.line.attribute.part " +
              "#{name}.polygon.attribute.part "
    sh "#{cat} >> #{name}.VCT"
end



desc "run ruby fake_vct.rb -o t1 -t t2"
task :test do
    sh "ruby fake_vct.rb -o t1 -t t2"
    merge_file(:t1)
    merge_file(:t2)
end

desc "run ruby fake_vct.rb -s 2000 -o t1 -t t2 -e 500000 -f 50000000  -i 20 -a 200"
task :t2000 do
    sh "ruby fake_vct.rb -s 2000 -o t1 -t t2 -e 500000 -f 50000000  -i 20 -a 200"
    merge_file(:t1)
    merge_file(:t2)
end

desc "run ruby fake_vct.rb -s 1000 -o t1 -t t2 -e 250000 -f 25000000 -i 20 -a 100"
task "t1000" do
    sh 'ruby fake_vct.rb -s 1000 -o t1 -t t2 -e 250000 -f 25000000 -i 20 -a 100'
    merge_file(:t1)
    merge_file(:t2)
end

task :default => :test
