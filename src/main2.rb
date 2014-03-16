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
        field = new FieldType(name,type,width,precision)
        @fields << field
        return field
    end

    def to_s
        value = []
        value << "#{@name},#{@fields.size}"
        @fields.each do |i|
            value << i.to_s
        end

        return value.join('\n')
    end
end

class Point
    attr_accessor :x,:y
    def initialize(x,y)
        @x=x
        @y=y
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

    def initialize(objectid,layerid,layername,point)
        @attr= {:objectid => objectid,
                :layerid  => layerid, 
                :layername=> layername,
                :num      => 1,
                :point    => point}
    end

    def to_s
        sprintf(@@template,@attr)
    end
end


class Line
    def initialize
        @point = []
    end

    def add(p)
        @point << p
    end

    def to_s
        @point.join('\n')
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

    def initialize(objectid,layerid,layername,point)
        @attr = {:objectid => objectid,
                 :layerid  => layerid,
                 :layername=> layername,
                 :type     => 1,
                 :num      => point.size,
                 :point    => point.join('\n')}
    end

    def to_s
        sprintf(@@template,@attr)
    end
end

class Polygon
    def initialize
        @lineid = []
    end

    def add(l)
        @lineid << l
    end

    def to_s
        @lineid.join(',') 
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

    def initialize(objectid,layerid,layername,line)
        @attr = {:objectid => objectid,
                 :layerid  => layerid,
                 :layername=> layername,
                 :point    => new Point(1,1),
                 :num      => line.size,
                 :line     => line.join(',')}
    end

    def to_s
        sprintf(@@template,@attr)
    end
end


class Attribute
    attr_accessor :objectid,:layerid
    def initialize(layerid,other)
        @layerid = layerid
        @other = other
    end

    def to_s
        "#{objectid},#{layerid},#{other.join(',')}"
    end
end

class Layer
    attr_accessor :id,:name,:type,:table,:field,:feats;
    def initialize(id,name,type,table,objectid,tabledefn)
        @id = id
        @name = name
        @type = type
        @table = table
        @field = tabledefn
        @flist = []
        @objectid = objectid
    end

    def create_feature(geo,attri)
        @objectid = @objectid +1

        attri.objectid = @objectid
        geo.objectid = @objectid

        feat = new VctFeature(@objectid,geo,attri)

        @flist << feat
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
        "id:\n#{@id}\ngeometry:\n#{@geometry}\nfield:\n#{@attribute}"
    end
end

class VctDataset
    attr_accessor :layers,:name,:srs,:field
    def initialize(name)
        @name = name
        @layers = []
        @prefix = {:name => 'layer',
                   :id   => '100',
                   :table=> 'table'}
        @layercode = 0
    end

    def create_layer(type,objectid,tabledefn)
        @layercode = @layercode +1
        layer = new Layer(@prefix[:id] + @layercode,
                          @prefix[:name] + @layercode,
                          type,
                          @prefix[:table] + @layercode,
                          objectid)
        @layers << layer
        return layer
    end

    def to_s
        "#{@name}:\n,#{@layers.join('\n')}"
    end
end

class VctFile
    def initialize(fileName, size) 
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

class VctCreater
    def initialize(vct_ds,size)
        @vct= vct_ds
        @pointNum = size ** 2
        @lineNum =  2 * size ** 2 - 2*size
        @polygonNum = (size - 1) ** 2
        @n = size

        # 这个要填
        @attr = []
        @table = []
    end

    def fake_head
        @vct.srs = <<HERE

HERE
    end

    def fake_point
        (1..@pointNum).each do |p|
            layer = @vct.create_layer("Point",p, @table) if p % 100 == 1
            i = (p - 1) / @n
            j = (p - 1) % @n

            point = new FPoint(layer.id,layer.name,new Point(i,j))
            attribute = new Attribute(layer.id,@attr)
            feat = layer.create_feature(point,attribute)
        end
    end

    def fake_line
        id = @pointNum
        (1..@lineNum).each do |l|
            id = id + l
            layer = @vct.create_layer("Line",id,@table) if l % 100 == 1
            start_point,end_point = calculate_line_point(l)

            pointNum = rand(1..10)
            points = generateLinePoint(start_point,end_point,pointNum)

            line = new FLine(layer.id,layer.name,points)
            attribute = new Attribute(layer.id,@attr)
            feat = layer.create_feature(line,attribute)
        end
    end

    def calculate_line_point(l)
        pstart =nil
        pend = nil
        if (l-1)%(2*@n-1) < (@n -1)
            i = (l-1)/(2*@n -1)
            j = (l-1)%(2*@n -1)
        elsif (l-1)%(2*@n -1) >= (@n-1)
            i = (l-1)/(2*@n -1)
            j = (l-n)%(2*@n -1)
            pstart = Point.new(i,j)
            pend = Point.new(i+1,j)
        end 
        return pstart,pend
    end

    def generateLinePoint(s,e,n)
        points = []
        width = (e.x-s.x).to_f/(n+1)
        heigh = (e.y-s.y).to_f/(n+1)

        points << s

        n.times do |n|
            point = Point.new(s.x + width*(n+1),s.y + heigh*(n+1))
            points << point
        end 

        points << e

        return points
    end

    def fake_polygon
        id = @pointNum + @lineNum 
        (1..@polygonNum).each do |k|
            id = id +1
            layer = @vct.create_layer("Polygon",id,@table) if k % 100 == 1

            l1 = (k-1)/(@n-1)*(2*@n-1) + (k-1)%(@n-1) +1
            l2 = l1+@n
            l3 = l1+2*@n-1 
            l4 = l1+@n-1 

            polygon = new FPolygon(layer.id,layer.name,
                        ["#{l1+@pointNum}",
                        "#{l2+@pointNum}",
                        "-#{l3+@pointNum}",
                        "-#{l4+@pointNum}"])

            attribute = new Attribute(layer.id,@attr)

            feat = layer.create_feature(polygon,attribute)
       end
    end

    def fake_table_structure
        @table = [] 
    end

    def fake_attribute
        @attribute = []
    end

    def fake
        fake_head()
        fake_table_structure()
        fake_attribute()
        fake_point()
        fake_line()
        fake_polygon()
    end
end

def dataset2file(vctds,vctfile)
    
end

def fake_vct(name,size)
    vct_ds   = new VctDataset(name)
    vct_fake = new VctCreater(vct_ds)
    vct_fake.fake
    return vct_ds
end

def create_file(name)
    return new VctFile(name)
end

def main(argv)
    size = argv[0] || 2
    name = argv[1] || 'TEST.VCT'
    vct_ds   = fake_vct(name,size)
    vct_file = create_file(name) 
    dataset2file(vct_ds,vct_file)
    vct_file.close
end

main(AEGV)