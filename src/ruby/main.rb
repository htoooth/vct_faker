require_relative "vctdataset"
require_relative "vctfile"
require_relative "vctcreator"
require_relative "vctgenerator"

def create_file(name)
    return VctFile.new(name)
end

def main(argv)
    size = argv[0] || 2
    name = argv[1] || 'TEST'

    vct_fake = VctCreator.new(size.to_i)
    vct_fake.fake()

    efc = EfcDatasetGenerator.new(vct_fake,name)
    efc_ds = efc.generate()
    vct_file_efc = create_file("#{name}_efc.VCT")
    dataset2file(efc_ds,vct_file_efc)
    vct_file_efc.close

    fci = FciDatasetGenerator.new(vct_fake,name)
    fci_ds = fci.generate()
    vct_file_fci = create_file("#{name}_fci.VCT")
    dataset2file(fci_ds,vct_file_fci)
    vct_file_fci.close

end

main(ARGV)