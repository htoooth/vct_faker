class VctGenerator
    def initialize(vctfake,name)
        @vct = VctDataset.new(name)
        @vctfake = vctfake

        @point_index = IndexFile.new("#{name}.point.index")
        @line_index = IndexFile.new("#{name}.line.index")
        @polygon_index = IndexFile.new("#{name}.polygon.index")

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
                if current_layer != nil
                    current_layer.close()
                end
                current_layer = @vct.create_layer("Point",@vctfake.table_define.clone)
            end
            point = FPoint.new(i.objectid,current_layer.id,current_layer.name,i)
            attribute = Attribute.new(i.objectid,current_layer.id,@vctfake.attribute_value)
            feat = current_layer.create_feature(point,attribute)
        end

        # add last feature if buff_feaure have features
        current_layer.close()
        @vct.file.close_point
    end

    def line
        current_layer = nil

        @vctfake.each_line do |i|
            if yield(i)
                if current_layer != nil
                    current_layer.close()
                end
                current_layer = @vct.create_layer("Line",@vctfake.table_define.clone)
            end
            line = FLine.new(i.objectid,current_layer.id,current_layer.name,i)
            attribute = Attribute.new(i.objectid,current_layer.id,@vctfake.attribute_value)
            feat = current_layer.create_feature(line,attribute)

            @line_index.write "#{i.objectid} #{i.size}"
        end

        current_layer.close()
        @vct.file.close_line
        @line_index.close
    end

    def polygon
        current_layer = nil

        @vctfake.each_polygon do |i|
            if yield(i)
                if current_layer != nil
                    current_layer.close()
                end
                current_layer = @vct.create_layer("Polygon",@vctfake.table_define.clone)
            end
            polygon = FPolygon.new(i.objectid,current_layer.id,current_layer.name,i)
            attribute = Attribute.new(i.objectid ,current_layer.id,@vctfake.attribute_value)
            feat = current_layer.create_feature(polygon,attribute){|feats| @vct.file.polygon.write_feature(feats)}

            @polygon_index.write "#{i.objectid} #{i.to_s}"
        end

        current_layer.close()
        @vct.file.close_polygon()
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
        @line = {}
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
            @line[i.objectid] = i.size
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
            point_count = 0
            i.eachLineId{|i| point_count += @line[i.to_i.abs]}
            b = if (sore == 0) or (sore >= @fci)
                true
                sore = 0
            else
                false
            end

            sore += point_count

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

