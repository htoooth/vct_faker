class VctFile
    def initialize(fileName) 
        if File.exist? fileName
            puts "#{fileName} is exist. Now delete!" 
            File.delete fileName
        end
        @file = File.new(fileName,"w")
        puts "============file start at #{Time::now}=================="
        puts "start write #{fileName}."
    end

    def head
        puts "start write HeadBegin."

        @file.puts 'HeadBegin'
        yield @file
        @file.puts 'HeadEnd'
        @file.puts

        puts "end write HeadEnd."
    end

    def feature
        puts 'start write FeatureCodeBegin.'

        @file.puts 'FeatureCodeBegin'
        yield @file
        @file.puts 'FeatureCodeEnd'
        @file.puts

        puts 'end write FeatureCodeEnd.'
    end

    def table
        puts 'start write TableStructureBegin.'

        @file.puts 'TableStructureBegin'
        yield @file
        @file.puts 'TableStructureEnd'
        @file.puts

        puts 'end write TableStructureEnd.'
    end

    def point
        puts 'start write PointBegin.'

        @file.puts 'PointBegin'
        yield @file
        @file.puts 'PointEnd'
        @file.puts

        puts 'end write PointEnd.'
    end

    def line
        puts 'start write LineBegin.'

        @file.puts 'LineBegin'
        yield @file
        @file.puts 'LineEnd'
        @file.puts

        puts 'end write LineEnd.'
    end

    def polygon
        puts 'start write PolygonBegin.'

        @file.puts 'PolygonBegin'
        yield @file
        @file.puts 'PolygonEnd'
        @file.puts

        puts 'end write PolygonEnd.'
    end

    def attribute
        puts 'start write AttributeBegin.'

        @file.puts 'AttributeBegin'
        @file.puts
        yield @file
        @file.puts 
        @file.puts 'AttributeEnd'

        puts 'end write AttributeEnd.'
    end

    def close
        @file.close
        puts "===========file end  at #{Time::now}==============="
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