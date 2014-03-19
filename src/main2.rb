require_relative "dataset"
require_relative "file"
require_relative "creator"
require_relative "generator"

def dataset2file(vctds,vctfile)
    vctfile.head do |f|
        f.puts vctds.srs
    end

    vctfile.feature do |f|
        vctds.layers.each { |i|  f.puts i }
    end

    vctfile.table do |f| 
        vctds.layers.each { |i| f.puts i.field  }
    end

    pointlayers = vctds.layers.select { |i|  i.type == "Point"}
    vctfile.point do |f|
        pointlayers.each do |l|
            l.feats.each do |feat|
                f.puts feat.geometry
            end
        end
    end

    linelayers = vctds.layers.select { |i| i.type == "Line"  }
    vctfile.line do |f|
        linelayers.each do |l|
            l.feats.each do | feat|
                f.puts feat.geometry
            end
        end
    end

    polygonlayers = vctds.layers.select { |i| i.type == "Polygon" }
    vctfile.polygon do |f|
        polygonlayers.each do |l|
            l.feats.each do | feat|
                f.puts feat.geometry
            end
        end
    end

    vctfile.attribute do |f|
        vctds.layers.each do |layer|
            f.puts layer.table
            layer.feats.each do |feat|
                f.puts feat.attribute
            end
            f.puts "TableEnd"
            f.puts 
        end
    end
    
end

def create_ds(name,size)
    vct_ds   = VctDataset.new(name)
    vct_fake = VctCreater.new(vct_ds,size) 
    return vct_ds,vct_fake
end

def fake_vct_efc(vctds,vctfake)
    vctfake.fake_efc
    return vctds,vctfake
end

def fake_vct_fci(vctds,vctfake)
    new_vct_ds = vctds.clone
    vctfake.vct = new_vct_ds
    vctfake.fake_fci
    return new_vct_ds,vctfake
end

def create_file(name)
    return VctFile.new(name)
end

def main(argv)
    size = argv[0] || 2
    name = argv[1] || 'TEST'
    vct_ds,vct_fake  = create_ds(name,size.to_i)

    efc_ds,efc_fake = fake_vct_efc(vct_ds,vct_fake)
    vct_file_efc = create_file("#{name}_efc.VCT")
    dataset2file(vct_ds,vct_file_efc)
    vct_file_efc.close

    fci_ds,fci_fake = fake_vct_fci(efc_ds,efc_fake)
    vct_file_fci = create_file("#{name}_fci.VCT")
    dataset2file(fci_ds,vct_file_fci)
    vct_file_fci.close

end

main(ARGV)