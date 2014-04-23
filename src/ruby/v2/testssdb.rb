require 'ssdb'

ssdb = SSDB.new

ssdb.set('ok','hello world')

puts ssdb.get('ok')