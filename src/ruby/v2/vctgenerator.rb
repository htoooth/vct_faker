class VctGenerator
    def initialize(vctfake,name)
        @vct = VctDataset.new(name)
        @vctfake = vctfake

        @point_index = IndexFile.new("#{name}.point")
        @line_index = IndexFile.new("#{name}.line")
        @polygon_index = IndexFile.new("#{name}.polygon")

        @feature_count = @vctfake.getCount

        @buff_feature = []
        @buff_size = 100

    end

    def head
        @vct.setSrs(@vctfake.srs)
        @vct.file.close_head
    end

    def point
        current_layer = nil

        @vctfake.each_point do |i|
            if yield(i)
                @vct.file.point.attribute.write_table_end() if current_layer != nil
                current_layer = @vct.create_layer("Point",@vctfake.table_define.clone)
                @vct.file.point.attribute.write_table_name(current_layer.table)
            end
            current_layer = @vct.create_layer("Point",@vctfake.table_define.clone) if yield(i)
            point = FPoint.new(i.objectid,current_layer.id,current_layer.name,i)
            attribute = Attribute.new(i.objectid,current_layer.id,@vctfake.attribute_value)
            feat = current_layer.create_feature(point,attribute)

            @buff_feature << feat
            if @buff_feature.size >= @buff_size
                @vct.file.point.write_feature(@buff_feature)
                @buff_feature.clear
            end
        end

        # add last feature if buff_feaure have features
        @vct.file.point.write_frush(@buff_feature)
        @buff_feature.clear
        @vct.file.point.attribute.write_table_end()
        @vct.file.close_point
    end

    def line
        current_layer = nil
        
        @vctfake.each_line do |i|
            if yield(i)
                @vct.file.line.attribute.write_table_end() if current_layer != nil
                current_layer = @vct.create_layer("Line",@vctfake.table_define.clone)
                @vct.file.line.attribute.write_table_name(current_layer.table)
            end
            line = FLine.new(i.objectid,current_layer.id,current_layer.name,i)
            attribute = Attribute.new(i.objectid,current_layer.id,@vctfake.attribute_value)
            feat = current_layer.create_feature(line,attribute)

            @buff_feature << feat
            if @buff_feature.size >= @buff_size
                @vct.file.line.write_feature(@buff_feature)
                @buff_feature.clear
            end

            @line_index.write "#{i.objectid} #{i.size}"
        end

        @vct.file.line.write_frush(@buff_feature)
        @buff_feature.clear
        @vct.file.line.attribute.write_table_end()
        @vct.file.close_line
        @line_index.close
    end

    def polygon
        current_layer = nil

        @vctfake.each_polygon do |i|
            if yield(i)
                @vct.file.polygon.attribute.write_table_end() if current_layer != nil
                current_layer = @vct.create_layer("Polygon",@vctfake.table_define.clone)
                @vct.file.polygon.attribute.write_table_name(current_layer.table) 
            end
            polygon = FPolygon.new(i.objectid,current_layer.id,current_layer.name,i)
            attribute = Attribute.new(i.objectid ,current_layer.id,@vctfake.attribute_value)
            feat = current_layer.create_feature(polygon,attribute)

            @buff_feature << feat
            if @buff_feature.size >= @buff_size
                @vct.file.polygon.write_feature(@buff_feature)
                @buff_feature.clear
            end

            @polygon_index.write "#{i.objectid} #{i.to_s}"

        end

        @vct.file.polygon.write_frush(@buff_feature)
        @buff_feature.clear
        @vct.file.polygon.attribute.write_table_end()
        @vct.file.close_polygon
        @polygon_index.close
    end

    def generate()
        @point_index.write "point_count #{@vctfake.getPointCount}"
        @point_index.write "feature_count #{@feature_count}"
        @point_index.write "task_count #{@vct.getLayerSize}"
        @point_index.close

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

