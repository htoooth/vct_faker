class Generator
    def initialize(vctfake,name)
        @vct = VctDataset.new(name)
        @vctfake = vctfake
        @current_layer = nil
    end

    def head
        @vct.srs = @srs
    end

    def point
        @vctfake.points.each do |i|
            @current_layer = @vct.create_layer("Point",@vctfake.table_define) if yield(i)
            point = FPoint.new(i.objectid,@current_layer.id,@current_layer.name,i)
            attribute = Attribute.new(i.objectid,@current_layer.id,@vctfake.attrbuet_value)
            feat = @current_layer.create_feature(point,attribute)
        end
    end

    def line
        @vctfake.lines.each do |i|
            @current_layer = @vct.create_layer("Line",@vctfake.table_define) if yield(i)
            line = FLine.new(i.objectid,@current_layer.id,@current_layer.name,i)
            attribute = Attribute.new(i.objectid,@current_layer.id,@vctfake.attrbuet_value)
            feat = @current_layer.create_feature(line,attribute)
        end
    end

    def polygon
        @vctfake.polygons.each do |i|
            @current_layer = @vct.create_layer("Polygon",@vctfake.table_define) if yield(i)
            polygon = FPolygon.new(i.objectid,@current_layer.id,@current_layer.name,i)
            attribute = Attribute.new(i.objectid ,@current_layer.id,@vctfake.attrbuet_value)
            feat = @current_layer.create_feature(polygon,attribute)
        end
    end

    def generate()
        return @vct
    end
end

class EfcDatasetGenerator < Generator
    def initialize(vctfake,name)
        super
    end 

    def point 
    end

    def line
    end

    def polygon
    end

    def generate()
        point()
        line()
        polygon()
        super
    end
end

class FciDatasetGenerator < Generator
    def initialize(vctfake,name)
        super
    end

    def point 
    end

    def line
    end

    def polygon
    end


    def generate()
        point()
        line()
        polygon()
        super
    end
end

