require_relative "vctdataset"
require_relative "vctfile"
require_relative "vctcreator"
require_relative "vctgenerator"

require "optparse"

def main(opt)
    size = opt[:size]
    name = opt[:target]
    efc = opt[:efc]
    fci = opt[:fci]
    linerange = (opt[:min]..opt[:max])

    puts "::fake_vct -s #{size} -t #{name} -e #{efc} -f #{fci} -i #{opt[:min]} -a #{opt[:max]}::"

    vct_fake = VctCreator.new(size.to_i,linerange)

    efc_name = "#{name}_efc.VCT"
    efc_index = "#{name}_efc.INDEX"
    fci_name = "#{name}_fci.VCT"
    fci_index = "#{name}_fci.INDEX"

    efc = EfcDatasetGenerator.new(vct_fake,efc_index,efc)
    efc_ds = efc.generate()
    efc_ds.close

    fci = FciDatasetGenerator.new(vct_fake,fci_index,fci)
    fci_ds = fci.generate()
    fci_ds.close
end

options = {:size   => 10,
           :target => 'TEST',
           :efc    => 100,
           :fci    => 100,
           :min    => 2,
           :max    => 20 }

opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: fake_vct OPTIONS"
  opt.separator  ""
  opt.separator  "default:"
  opt.separator  "fake_vct -s 10 -t TEST -e 100 -f 100 -i 2 -a 20"
  opt.separator  ""
  opt.separator  "Options"

  opt.on("-s","--size SIZE","which size you want vct include points") do |size|
    options[:size] = size
  end

  opt.on("-t","--target FILE_NAME","generate file name") do |target|
    options[:target] = target
  end

  opt.on("-e","--efc EFC",Integer,"equal feature count") do |efc|
    options[:efc] = efc
  end

  opt.on("-f","--fci FCI",Integer,"feature computing index") do |fci|
    options[:fci] = fci
  end

  opt.on("-i","--min MIN",Integer,"min number of line point range ") do |i|
    options[:min] = i
  end

  opt.on("-a","--max MAX",Integer,"max number of line point range") do |a|
    options[:max] = a
  end

  opt.on('-c','--compute SIZE',Integer,"compute number of point, line and polygon") do |size|
    pointNum = size ** 2
    lineNum = 2 * size ** 2 - 2*size
    polygonNum = (size - 1) ** 2

    puts "Generate geometrys:"
    puts "Point  :#{pointNum}"
    puts "Line   :#{lineNum}"
    puts "Polygon:#{polygonNum}"
    exit
  end

  opt.on("-h","--help","help") do
    puts opt_parser
    exit
  end
end

opt_parser.parse!

main(options)

