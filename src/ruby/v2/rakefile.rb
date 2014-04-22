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



desc "test"
task :test do
     sh "ruby fake_vct.rb -t t1 -o t2"
     merge_file(:t1)
     merge_file(:t2)
end

task :default => :test
