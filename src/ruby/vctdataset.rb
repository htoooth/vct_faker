class FieldType
    attr_accessor :name,:type,:width,:precision
    def initialize(name,type,width,precision)
        @name = name
        @type = type
        @width = width
        @precision = precision
    end

    def to_s
        "#{@name},#{@type},#{@width},#{@precision}"
    end
end

class Table
    attr_accessor :name,:fields
    def initialize(name)
        @name = name
        @fields = []
    end

    def create_field(name,type,width,precision)
        field = FieldType.new(name,type,width,precision)
        @fields << field
        return field
    end

    def to_s
        value = []
        value << "#{@name},#{@fields.size}"
        @fields.each do |i|
            value << i.to_s
        end

        return value.join("\n")
    end

    def clone()
        t = Table.new(@name)
        t.fields = @fields
        return t
    end
end

class Point
    attr_accessor :objectid,:x,:y
    def initialize(x,y)
        @x=x
        @y=y
    end

    def size
        1
    end

    def to_s
        "#{@x},#{@y}"
    end
end

class FPoint
    @@template = <<HERE
%<objectid>d
%<layerid>s
%<layername>s
%<num>d
%<point>s
HERE

    attr_accessor :objectid,:layerid,:layername,:geometry
    def initialize(objectid,layerid,layername,point)
        @layerid = layerid
        @layername = layername
        @objectid = objectid
        @geometry = point

        @attribute= {:objectid => @objectid,
                     :layerid  => @layerid, 
                     :layername=> @layername,
                     :num      => 1,
                     :point    => @geometry}
    end

    def to_s
        sprintf(@@template,@attribute)
    end

end


class Line
    attr_accessor :objectid
    def initialize
        @points = []
    end

    def add(p)
        @points << p
    end

    def size
        @points.size
    end

    def to_s
        @points.join("\n")
    end
end

class FLine
    @@template = <<HERE
%<objectid>d
%<layerid>s
%<layername>s
%<type>s
%<num>d
%<point>s
HERE

    attr_accessor :objectid,:layerid,:layername,:geometry
    def initialize(objectid,layerid,layername,points)
        @objectid = objectid
        @layerid = layerid
        @layername = layername
        @geometry = points

        @attr = {:objectid => @objectid,
                 :layerid  => @layerid,
                 :layername=> @layername,
                 :type     => 1,
                 :num      => @geometry.size,
                 :point    => @geometry}
    end

    def to_s
        sprintf(@@template,@attr)
    end

end

class Polygon
    attr_accessor :objectid
    def initialize
        @lineid = []
    end

    def add(l)
        @lineid << l
    end

    def eachLineId
        @lineid.each { |e| yield(e) }
    end

    def size
        @lineid.size
    end

    def to_s
        @lineid.join(",") 
    end
end

class FPolygon
    @@template = <<HERE
%<objectid>d
%<layerid>s
%<layername>s
%<point>s
%<num>d
%<line>s
HERE

    attr_accessor :objectid,:layerid,:layername,:geometry
    def initialize(objectid,layerid,layername,lines)
        @objectid = objectid
        @layerid = layerid
        @layername = layername
        @geometry = lines

        @attr = {:objectid => @objectid,
                 :layerid  => @layerid,
                 :layername=> @layername,
                 :point    => Point.new(1,1),
                 :num      => @geometry.size,
                 :line     => @geometry}
    end

    def to_s
        sprintf(@@template,@attr)
    end
end


class Attribute
    def initialize(objectid,layerid,other)
        @objectid = objectid
        @layerid = layerid
        @other = other
    end

    def to_s
        "#{@objectid},#{@layerid},#{@other.join(',')}"
    end
end

class Layer
    attr_accessor :id,:name,:type,:table,:field,:feats;
    def initialize(id,name,type,table,tabledefn)
        @id = id
        @name = name
        @type = type
        @table = table
        @field = tabledefn
        @field.name = table
        @feats = []
    end

    def create_feature(geo,attri)
        feat = VctFeature.new(geo.objectid,geo,attri)
        @feats << feat
        return feat
    end

    def to_s
        "#{@id},#{@name},#{@type},0,0,0,#{@table}"
    end
end

class VctFeature
    attr_accessor :id,:geometry,:attribute
    def initialize(id,geo,attri)
        @geometry = geo
        @attribute = attri
        @id = id
    end

    def to_s
        "id=:#{@id}\ngeometry=:\n#{@geometry}field=:#{@attribute}\n==="
    end
end

class VctDataset
    attr_accessor :layers,:name,:srs
    def initialize(name)
        @name = name
        @layers = []
        @prefix = {:name => 'layer',
                   :id   => '100',
                   :table=> 'table'}
        @layercode = 0
    end

    def create_layer(type,tabledefn)
        @layercode = @layercode +1
        layer = Layer.new(@prefix[:id] + @layercode.to_s,
                          @prefix[:name] + @layercode.to_s,
                          type,
                          @prefix[:table] + @layercode.to_s,
                          tabledefn)
        @layers << layer
        return layer
    end

    def getLayerSize
        @layers.size
    end

    def to_s
        "#{@name}:\n,#{@layers.join("\n")}"
    end
    
end
