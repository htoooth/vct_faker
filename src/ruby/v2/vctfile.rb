
$config = {
    :Head        => {:prefix => ['HeadBegin',"HeadEnd"]},
    :FeatureCode => {:prefix => ['FeatureCodeBegin',"FeatureCodeEnd"]},
    :Table       => {:prefix => ['TableBegin',"TableEnd"]},
    :Point       => {:prefix => ['PointBegin',"PointEnd"]},
    :Line        => {:prefix => ['LineBegin',"LineEnd"]},
    :Polygon     => {:prefix => ['PolygonBegin',"PolygonEnd"]},
    :Attribute   => {:prefix => ['AttributeBegin',"AttributeEnd"]}
}

class VctFile
    attr_accessor :head,:featurecode,:table,:point,:line,:polygon
    def initialize(name)
        @name = name
        @head = HeadPart.new(@name) 
        @featurecode =  LayerPart.new(@name)
        @table = TablePart.new(@name)
        @point = PointPart.new(@name)
        @line = LinePart.new(@name)
        @polygon = PolygonPart.new(@name)
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
        close_featurecode()
        close_table()
        puts "=========#{Time::now}==========="
    end

    def close_point
        @point.close
    end

    def close_line
        @line.close
    end

    def close_polygon
        @polygon.close
    end

    def close_head
        @head.close
    end

    def close_featurecode
        @featurecode.close
    end

    def close_table
        @table.close
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
        write("\n")
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
    def initialize(name)
        super("#{name}.head.part",:Head)
    end
end

class LayerPart < VctPart
    def initialize(name)
        super("#{name}.featurecode.part",:FeatureCode)
    end
end

class TablePart < VctPart
    def initialize(name)
        super("#{name}.table.part",:Table)
    end

end

class PointPart < VctPart
    attr_accessor :attribute
    def initialize(name)
        super("#{name}.point.geometry.part",:Point)
        @attribute = PointAttribute.new(name)
    end

    def write_feature(feats)
        buff_geo = ''
        buff_attri = ''

        return 0 if feats.size == 0

        feats.each do |i|
            buff_geo += i.geometry.to_s
            buff_attri += i.attribute.to_s
        end

        @file.write(buff_geo)
        @attribute.write(buff_attri)
    end

    def write_frush(feats)
        write_feature(feats)
    end

    def close
        super()
        @attribute.close
    end
end

class LinePart < VctPart
    attr_accessor :attribute
    def initialize(name)
        super("#{name}.line.geometry.part",:Line)
        @attribute = LineAttribute.new(name)
    end

    def write_feature(feats)
        buff_geo = ''
        buff_attri = ''

        return 0 if feats.size == 0

        feats.each do |i|
            buff_geo += i.geometry.to_s
            buff_attri += i.attribute.to_s
        end

        @file.write(buff_geo)
        @attribute.write(buff_attri)
    end

    def write_frush(feats)
        write_feature(feats)
    end

    def close
        super()
        @attribute.close
    end
end

class PolygonPart < VctPart
    attr_accessor :attribute
    def initialize(name)
        super("#{name}.polygon.geometry.part",:Polygon)
        @attribute = PolygonAttribute.new(name)
    end

    def write_feature(feats)
        buff_geo = ''
        buff_attri = ''

        return 0 if feats.size == 0

        feats.each do |i|
            buff_geo += i.geometry.to_s
            buff_attri += i.attribute.to_s
        end

        @file.write(buff_geo)
        @attribute.write(buff_attri)
    end

    def write_frush(feats)
        write_feature(feats)
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
    def initialize(name)
        super("#{name}.point.attribute.part")
        write_begin()
    end

    def write_begin
        write($config[:Attribute][:prefix][0])
    end

end

class LineAttribute < AttributePart
    def initialize(name)
        super("#{name}.line.attribute.part")
    end
end

class PolygonAttribute < AttributePart
    def initialize(name)
        super("#{name}.polygon.attribute.part")
    end

    def write_end
        write($config[:Attribute][:prefix][1])
    end

    def close
        write_end()
        super()
    end
end