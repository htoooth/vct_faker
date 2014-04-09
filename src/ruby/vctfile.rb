class VctFile
    def initialize(fileName) 
        if File.exist? fileName
            puts "#{fileName} is exist. Now delete!" 
            File.delete fileName
        end
        @file = File.new(fileName,"w")
    end

    def head
        @file.puts 'HeadBegin'
        yield @file
        @file.puts 'HeadEnd'
        @file.puts
    end

    def feature
        @file.puts 'FeatureCodeBegin'
        yield @file
        @file.puts 'FeatureCodeEnd'
        @file.puts
    end

    def table
        @file.puts 'TableStructureBegin'
        yield @file
        @file.puts 'TableStructureEnd'
        @file.puts
    end

    def point
        @file.puts 'PointBegin'
        yield @file
        @file.puts 'PointEnd'
        @file.puts
    end

    def line
        @file.puts 'LineBegin'
        yield @file
        @file.puts 'LineEnd'
        @file.puts
    end

    def polygon
        @file.puts 'PolygonBegin'
        yield @file
        @file.puts 'PolygonEnd'
        @file.puts
    end

    def attribute
        @file.puts 'AttributeBegin'
        @file.puts
        yield @file
        @file.puts 
        @file.puts 'AttributeEnd'
    end

    def close
        @file.close
    end

    def save
        
    end
    
end

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