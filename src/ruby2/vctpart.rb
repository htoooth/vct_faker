head_template =''
feature_template = ''
table_template = ''
point_template = ''
line_template = ''
polygon_template = ''
attribute_template = ''

$config = {
    :Head        => {:prefix => ['HeadBegin','HeadEnd'],:template =>head_template },
    :FeatureCode => {:prefix => ['FeatureCodeBegin','FeatureCodeEnd'],:template => feature_template},
    :Table       => {:prefix => ['TableBegin','TableEnd'], :template => table_template},
    :Point       => {:prefix => ['PointBegin','PointEnd'], :template =>point_template},
    :Line        => {:prefix => ['LineBegin','LineEnd'],   :template =>line_template},
    :Polygon     => {:prefix => ['PolygonBegin','PolygonEnd', :template =>polygon_template]},
    :Attribute   => {:prefix => ['AttributeBegin','AttributeEnd'], :template => attribute_template}
}

class VctFile 
    attr_accessor :head,:featurecode,:table,:point,:line,:polygon
    def initialize(name)
        @name = name
        @head = HeadPart.new() 
        @featurecode =  LayerPart.new()
        @table = TablePart.new()
        @point = PointPart.new()
        @line = LinePart.new()
        @polygon = PolygonPart.new()
    end

    def write_head(str)
        @head.write(str)
    end

    def write_featurecode(str)
        @featurecode.write(str)
    end

    def write_table(str)
        @table.write(str)
    end

    def write_point(feats)
        @point.write_feature(feat)
    end

    def write_line(feats)
        @line.write_feature(feats)
    end

    def write_polygon(feats)
        @polygon.write_feature(feats)
    end

    def close
        @head.close
        @featurecode.close
        @table.close
        @point.close
        @line.close
        @polygon.close
    end
end

class VctPart
    def initialize(name,key)
        @name = name
        @file = File.new(name,'w')
        @key = key
        begin_str()
    end

    def write(str)
        @file.puts(str)
    end

    def begin_str
        write(getBegin(@key))
    end

    def end_str
        write(getEnd(@key))
    end

    def close
        end_str()
        @file.close
    end

    def getValue(key,num)
        $config[key][:prefix][num]
    end

    def getBegin(key)
        getValue(key,0)
    end

    def getEnd(key)
        getValue(key,1)
    end
end

class HeadPart < VctPart
    def initialize
        super('z.head.part',:Head)
    end
end

class LayerPart < VctPart
    def initialize
        super("z.#{@name}.featureCode.part",:FeatureCode)
    end
end

class TablePart < VctPart
    def initialize
        super("z.#{@name}.table.part",:Table)
    end

end

class PointPart < VctPart
    attr_accessor :attribute
    def initialize
        super("z.#{@name}.point.geometry.part",:Point)
        @attribute = PointAttribute.new()
    end

    def write_feature(feats)
        buff_geo = ''
        buff_attri = ''
        feats.each do |i|
            buff_geo += i.geometry.to_s
            buff_attri += i.attribute.to_s
        end

        @file.write(buff_geo)
        @attribute.write(buff_attri)
    end

    def close
        super()
        @attribute.close
    end
end

class LinePart < VctPart
    attr_accessor :attribute
    def initialize
        super("z.#{@name}.line.geometry.part",:Line)
        @attribute = LineAttribute.new()
    end

    def write_feature(feats)
        buff_geo = ''
        buff_attri = ''
        feats.each do |i|
            buff_geo += i.geometry.to_s
            buff_attri += i.attribute.to_s
        end

        @file.write(buff_geo)
        @attribute.write(buff_attri)
    end

    def close
        super()
        @attribute.close
    end
end

class PolygonPart < VctPart
    attr_accessor :attribute
    def initialize
        super("z.#{@name}.polygon.geometry.part",:Polygon)
        @attribute = PolygonAttribute.new()
    end

    def write_feature(feats)
        buff_geo = ''
        buff_attri = ''
        feats.each do |i|
            buff_geo += i.geometry.to_s
            buff_attri += i.attribute.to_s
        end

        @file.write(buff_geo)
        @attribute.write(buff_attri)
    end

    def close
        super()
        @attribute.close
    end
end

class AttributePart
    def initialize(name)
        @file = File.new(name,'w')
    end

    def write(str)
        @file.puts(str)
    end

    def write_begin
    end

    def write_end
    end

    def write_table_name(str)
        write(str)
    end

    def write_table_end
        write('TableEnd')
    end

    def close
        @file.close
    end
end

class PointAttribute < AttributePart
    def initialize
        super("z.#{@name}.point.attribute.part")
        write_begin()
    end

    def write_begin
        write($config[:Attribute][:prefix][0])
    end

end

class LineAttribute < AttributePart
    def initialize
        super("z.#{@name}.line.attribute.part")
    end
end

class PolygonAttribute < AttributePart
    def initialize
        super("z.#{@name}.polygon.attribute.part")
    end

    def write_end
        write($config[:Attribute][:prefix][1])
    end

    def close
        write_end()
        super()
    end
end