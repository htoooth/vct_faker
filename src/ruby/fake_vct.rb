require_relative "vctdataset"
require_relative "vctfile"
require_relative "vctcreator"
require_relative "vctgenerator"

require "optparse"

def create_file(name)
    return VctFile.new(name)
end

def main(opt)
    size = opt[:size]
    name = opt[:target]
    efc = opt[:efc]
    fci = opt[:fci]
    linerange = (opt[:min]..opt[:max])

    puts "fake_vct -s #{size} -t #{name} -e #{efc} -f #{fci} -i #{opt[:min]} -a #{opt[:max]}"

    vct_fake = VctCreator.new(size.to_i,linerange)
    vct_fake.fake()

    efc = EfcDatasetGenerator.new(vct_fake,name,efc)
    efc_ds = efc.generate()
    vct_file_efc = create_file("#{name}_efc.VCT")
    dataset2file(efc_ds,vct_file_efc)
    vct_file_efc.close

    fci = FciDatasetGenerator.new(vct_fake,name,fci)
    fci_ds = fci.generate()
    vct_file_fci = create_file("#{name}_fci.VCT")
    dataset2file(fci_ds,vct_file_fci)
    vct_file_fci.close

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

  opt.on("-h","--help","help") do
    puts opt_parser
    exit
  end
end

opt_parser.parse!

main(options)

