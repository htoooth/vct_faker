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
    
end