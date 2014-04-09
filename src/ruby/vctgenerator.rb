class VctGenerator
    def initialize(vctfake,name)
        @vct = VctDataset.new(name)
        @vctfake = vctfake
        @current_layer = nil
    end

    def head
        @vct.srs = @vctfake.srs
    end

    def point
        @vctfake.points.each do |i|
            @current_layer = @vct.create_layer("Point",@vctfake.table_define.clone) if yield(i)
            point = FPoint.new(i.objectid,@current_layer.id,@current_layer.name,i)
            attribute = Attribute.new(i.objectid,@current_layer.id,@vctfake.attribute_value)
            feat = @current_layer.create_feature(point,attribute)
        end
    end

    def line
        @vctfake.lines.each do |i|
            @current_layer = @vct.create_layer("Line",@vctfake.table_define.clone) if yield(i)
            line = FLine.new(i.objectid,@current_layer.id,@current_layer.name,i)
            attribute = Attribute.new(i.objectid,@current_layer.id,@vctfake.attribute_value)
            feat = @current_layer.create_feature(line,attribute)
        end
    end

    def polygon
        @vctfake.polygons.each do |i|
            @current_layer = @vct.create_layer("Polygon",@vctfake.table_define.clone) if yield(i)
            polygon = FPolygon.new(i.objectid,@current_layer.id,@current_layer.name,i)
            attribute = Attribute.new(i.objectid ,@current_layer.id,@vctfake.attribute_value)
            feat = @current_layer.create_feature(polygon,attribute)
        end
    end

    def generate()
        return @vct
    end
end

class EfcDatasetGenerator < VctGenerator
    def initialize(vctfake,name)
        super
        @efc = 100
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
    def initialize(vctfake,name)
        super
        @fci = 100
    end

    def point
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

