class Vct
    def initialize(rows,columns,fileName) 
        @rows = rows
        @columns = columns
        if File.exist? fileName
            puts "#{fileName} is exist. Now delete!" 
            File.delete fileName
        end
        @file = File.new(fileName, "w")
    end

    def head(text)
        @file.puts 'HeadBegin'
        yield text,@file
        @file.puts 'HeadEnd'
        @file.puts
    end

    def feature(text)
        @file.puts 'FeatureCodeBegin'

        yield text,@file
        @file.puts 'FeatureCodeEnd'
        @file.puts
    end

    def table(text)
        @file.puts 'TableStructureBegin'
        yield text,@file
        @file.puts 'TableStructureEnd'
        @file.puts
    end

    def point(text)
        @file.puts 'PointBegin'
        yield text,@file
        @file.puts 'PointEnd'
        @file.puts
    end

    def line(text)
        @file.puts 'LineBegin'
        yield text,@file
        @file.puts 'LineEnd'
        @file.puts
    end

    def polygon(text)
        @file.puts 'PolygonBegin'
        yield text,@file
        @file.puts 'PolygonEnd'
        @file.puts
    end

    def attribute(text)
        @file.puts 'AttributeBegin'
        yield text,@file
        @file.puts 'AttributeEnd'
    end

    def close
        @file.close
    end

end


=begin
 start main
=end

filename = 'TEST.VCT'

vct = Vct.new 1000,1000,filename

vct.head 'head' do |body,file|

end

vct.feature 'feature' do |body,file|

end

vct.table 'table' do |body,file|

end

vct.point 'point' do |body,file|

end

vct.line 'line' do |body,file|

end

vct.polygon 'polygon' do |body,file|

end

vct.attribute 'attribute' do |body,file|

end



vct.close



