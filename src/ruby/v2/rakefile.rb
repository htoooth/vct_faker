require 'rake/clean'

CLEAN.include('*.VCT')
CLEAN.include('*.part')
CLEAN.include('*.point')
CLEAN.include('*.line')
CLEAN.include('*.polygon')

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


desc "test"
task :test do
     system 'ruby fake_vct.rb'
end

task :default => :test
