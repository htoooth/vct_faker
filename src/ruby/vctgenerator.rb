class VctGenerator
    def initialize(vctfake,name)
        @vct = VctDataset.new(name)
        @vctfake = vctfake
        @current_layer = nil

        @point_index = IndexFile.new("#{name}.point")
        @line_index = IndexFile.new("#{name}.line")
        @polygon_index = IndexFile.new("#{name}.polygon")

        @feature_count = @vctfake.points.size + @vctfake.lines.size + @vctfake.polygons.size

        puts "==========generator start at #{Time::now}=============="
    end

    def head
        @vct.srs = @vctfake.srs
    end

    def point
        puts "#{@vct.name} generate points."
        @vctfake.points.each do |i|
            @current_layer = @vct.create_layer("Point",@vctfake.table_define.clone) if yield(i)
            point = FPoint.new(i.objectid,@current_layer.id,@current_layer.name,i)
            attribute = Attribute.new(i.objectid,@current_layer.id,@vctfake.attribute_value)
            feat = @current_layer.create_feature(point,attribute)
        end
        puts "points done."
    end

    def line
        puts "#{@vct.name} generate lines."
        @vctfake.lines.each do |i|
            @current_layer = @vct.create_layer("Line",@vctfake.table_define.clone) if yield(i)
            line = FLine.new(i.objectid,@current_layer.id,@current_layer.name,i)
            attribute = Attribute.new(i.objectid,@current_layer.id,@vctfake.attribute_value)
            feat = @current_layer.create_feature(line,attribute)

            @line_index.write "#{i.objectid} #{i.size}"
        end
        @line_index.close
        puts 'lines done.'
    end

    def polygon
        puts "#{@vct.name} generate polygons at #{Time::now}."
        @vctfake.polygons.each do |i|
            @current_layer = @vct.create_layer("Polygon",@vctfake.table_define.clone) if yield(i)
            polygon = FPolygon.new(i.objectid,@current_layer.id,@current_layer.name,i)
            attribute = Attribute.new(i.objectid ,@current_layer.id,@vctfake.attribute_value)
            feat = @current_layer.create_feature(polygon,attribute)

            # each polygon point count
            point_count = 0
            line_index=[]
            i.eachLineId do |l|
                line_index << @vctfake.lines.index do |e| 
                    e.objectid == l.to_i.abs
                end
                line_index.each { |e| point_count += @vctfake.lines[e].size }
            end
            @polygon_index.write "#{i.objectid} #{point_count}"

        end
        @polygon_index.close
        puts "polygons done at #{Time::now}"
    end

    def generate()
        @point_index.write "point_count #{@vctfake.points.size}"
        @point_index.write "feature_count #{@feature_count}"
        @point_index.write "task_count #{@vct.getLayerSize}"
        @point_index.close

        puts "==========generator end at #{Time::now}=============="
        return @vct
    end
end

class EfcDatasetGenerator < VctGenerator
    def initialize(vctfake,name,efc)
        super(vctfake,name)
        @efc = efc 
    end

    def point
        num = 1
        super do |i|
            b = if num % @efc == 1
                true
            else
                false
            end
            num +=1
            b
        end
    end

    def line
        num = 1
        super do |i|
            b = if num % @efc == 1
                true
            else
                false
            end
            num +=1
            b
        end
    end

    def polygon
        num = 1
        super do |i|
            b = if num % @efc == 1
                true
            else
                false
            end
            num +=1
            b
        end
    end

    def generate()
        head()
        point()
        line()
        polygon()
        super
    end
end

class FciDatasetGenerator < VctGenerator
    def initialize(vctfake,name,fci)
        super(vctfake,name)
        @fci = fci
    end

    def point
        sore = 0
        super do |i|
            b = if (sore == 0) or (sore >= @fci)
                sore = 0
                true
            else
                false
            end

            sore += i.size

            b
        end
    end

    def line
        sore = 0
        super do |i|
            b = if (sore == 0) or (sore >= @fci)
                true
                sore = 0
            else
                false
            end

            sore += i.size

            b
        end
    end

    def polygon
        sore = 0
        super do |i|
            b = if (sore == 0) or (sore >= @fci)
                true
                sore = 0
            else
                false
            end

            sore += i.size

            b
        end
    end

    def generate()
        head()
        point()
        line()
        polygon()
        super
    end
end

class IndexFile
    def initialize(fileName)
        if File.exist? fileName
            puts "#{fileName} is exist. Now delete!" 
            File.delete fileName
        end
        @file = File.new(fileName,"w")
    end

    def write(context)
        @file.puts context
    end

    def close
        @file.close
    end
end

