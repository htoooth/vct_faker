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
    attr_accessor :x,:y
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

    def clone
        FPoint.new(@objectid,@layerid,@layername,@geometry)
    end
end


class Line
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

    def clone
        FLine.new(@objectid,@layerid,@layername,@geometry)
    end
end

class Polygon
    def initialize
        @lineid = []
    end

    def add(l)
        @lineid << l
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

    def clone
        FPolygon.new(@objectid,@layerid,@layername,@geometry)
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
    def initialize(id,name,type,table,objectid,tabledefn)
        @id = id
        @name = name
        @type = type
        @table = table
        @field = tabledefn
        @objectid = objectid
        @field.name = table
        @feats = []
    end

    def create_feature(geo,attri)
        feat = VctFeature.new(@objectid,geo,attri)

        @objectid += 1
        @feats << feat
        return feat
    end

    def get_next_id
        return @objectid 
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

    def create_layer(type,objectid,tabledefn)
        @layercode = @layercode +1
        layer = Layer.new(@prefix[:id] + @layercode.to_s,
                          @prefix[:name] + @layercode.to_s,
                          type,
                          @prefix[:table] + @layercode.to_s,
                          objectid,
                          tabledefn)
        @layers << layer
        return layer
    end

    def to_s
        "#{@name}:\n,#{@layers.join("\n")}"
    end

    def clone
       vctds = VctDataset.new(@name)
       vctds.srs = @srs
       return vctds
    end
end

class VctFile
    def initialize(fileName) 
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
        @file.puts
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
    attr_accessor :vct
    attr_accessor :points,:lines,:polygons
    def initialize(vct_ds,size)
        @pointNum = size ** 2
        @lineNum =  2 * size ** 2 - 2*size
        @polygonNum = (size - 1) ** 2
        @n = size

        @vct= vct_ds
        @srs = ''
        @attr = []
        @table = Table.new("test")
        @points={}
        @lines= {}
        @polygons= {}
    end

    def fake_head
        @srs = <<HERE
Datamark: LANDUSE.VCTFILE
Version: 2.0
Unit: M
Dim: 2
Topo: 1
Coordinate: M
Projection: Gauss-Krueger Projection
Spheroid: IAG-75 Spheroid
Parameters: 6378140,6356755
Meridinan: 114
MinX: 38394015.414
MinY:  3103134.261
MaxX: 38401706.631
MaxY:  3120945.278
Scale: 10000
Date: 20100611
Separator: ,
HERE
    end

    def fake_point
        layer = nil
        (1..@pointNum).each do |p|
            layer = @vct.create_layer("Point",p, @table.clone) if p % 100 == 1
            i = (p - 1) / @n
            j = (p - 1) % @n

            objectid = layer.get_next_id

            point = FPoint.new(objectid,layer.id,layer.name,Point.new(i,j))
            attribute = Attribute.new(objectid,layer.id,@attr)
            feat = layer.create_feature(point,attribute)

        end
    end

    def fake_line
        id = @pointNum
        layer = nil
        (1..@lineNum).each do |l|
            oid = id + l
            pointNum = rand(100..100000)
            start_point,end_point = calculate_line_point(l)
            geoline = generateLinePoint(start_point,end_point,pointNum)

            layer = @vct.create_layer("Line",oid,@table.clone) if l % 100 == 1
            objectid = layer.get_next_id

            line = FLine.new(objectid,layer.id,layer.name,geoline)
            attribute = Attribute.new(objectid,layer.id,@attr)
            feat = layer.create_feature(line,attribute)

        end
    end

    def calculate_line_point(l)
        pstart =nil
        pend = nil
        if (l-1)%(2*@n-1) < (@n -1)
            i = (l-1)/(2*@n -1)
            j = (l-1)%(2*@n -1)
            pstart = Point.new(i,j)
            pend = Point.new(i,j+1)
        elsif (l-1)%(2*@n -1) >= (@n-1)
            i = (l-1)/(2*@n -1)
            j = (l-@n)%(2*@n -1)
            pstart = Point.new(i,j)
            pend = Point.new(i+1,j)
        end
        return pstart,pend
    end

    def generateLinePoint(s,e,n)
        line = Line.new()
        width = (e.x-s.x).to_f/(n+1)
        heigh = (e.y-s.y).to_f/(n+1)

        line.add(s)

        n.times do |n|
            point = Point.new(s.x + width*(n+1),s.y + heigh*(n+1))
            line.add(point)
        end

        line.add(e)

        return line
    end

    def fake_polygon
        id = @pointNum + @lineNum
        layer = nil
        (1..@polygonNum).each do |k|
            oid = id +k

            l1 = (k-1)/(@n-1)*(2*@n-1) + (k-1)%(@n-1) +1
            l2 = l1+@n
            l3 = l1+2*@n-1 
            l4 = l1+@n-1 

            layer = @vct.create_layer("Polygon",oid,@table.clone) if k % 100 == 1
            objectid = layer.get_next_id

            geopolygon = Polygon.new()

            geopolygon.add "#{l1+@pointNum}"
            geopolygon.add "#{l2+@pointNum}"
            geopolygon.add "-#{l3+@pointNum}"
            geopolygon.add "-#{l4+@pointNum}"

            polygon = FPolygon.new(objectid,layer.id,layer.name,geopolygon)

            attribute = Attribute.new(objectid ,layer.id,@attr)

            feat = layer.create_feature(polygon,attribute)
       end
   end

   def fake_table_structure

        t = <<HERE
BSM,Integer,10
YSDM,Char,10
KZDMC,Char,50
KZDDH,Char,10
KZDLX,Char,10
KZDDJ,Char,30
BSLX,Char,2
BZLX,Char,2
KZDZT,Char,100
DZJ,Varbin
X80,Float,10,3
Y80,Float,10,3
Z80,Float,10,3
X54,Float,10,3
Y54,Float,10,3
Z54,Float,10,3
HERE
        fields = t.split("\n")

        fields.each do |f|
            field = f.split(',')
            if field.size < 4
                field << 0
                field << 0
            end
            n,t,w,p = field
            @table.create_field(n,t,w,p)
        end
    end

    def fake_attribute
        @attr = ["xxmc","iwea","zjfda",
                "vlfda","et","md","rhw","fhc",
                2.9,3.2,2.2,
                4.5,3.2,2.1]
    end

    def fake_efc
        fake_head()
        fake_efc_head()
        fake_table_structure()
        fake_attribute()
        fake_point()
        fake_line()
        fake_polygon()
    end

    def fake
       fake_head()
       fake_table_structure()
       fake_efc_point() 
       fake_efc_line()
       fake_ecf_polygon()
       fake_attribute()
    end

    def fake_efc_head
        @vct.srs = @srs
    end

    def fake_efc_point
        (1..@pointNum).each do |p|
            objectid = p
            i = (p - 1) / @n
            j = (p - 1) % @n 
            @points[objectid] = Point.new(i,j)
        end
    end

    def fake_efc_line
        id = @pointNum
        (1..@lineNum).each do |l|
            objectid = id + l
            pointNum = rand(100..100000)
            start_point,end_point = calculate_line_point(l)
            line = generateLinePoint(start_point,end_point,pointNum)
            @lines[objectid] = line
        end
    end

    def fake_efc_polygon
        id = @pointNum + @lineNum
        (1..@polygonNum).each do |k|
            objectid = id +k

            l1 = (k-1)/(@n-1)*(2*@n-1) + (k-1)%(@n-1) +1
            l2 = l1+@n
            l3 = l1+2*@n-1 
            l4 = l1+@n-1 

            polygon = Polygon.new()
            polygon.add "#{l1+@pointNum}"
            polygon.add "#{l2+@pointNum}"
            polygon.add "-#{l3+@pointNum}"
            polygon.add "-#{l4+@pointNum}"

            @polygons[objectid] = polygon
       end
    end

    def fake_fci
        fake_fci_point()
        fake_fci_line()
        fake_fci_polygon()
    end

    def fake_fci_point
        #TODO
    end

    def fake_fci_line
        #TODO
    end

    def fake_fci_polygon
        #TODO
    end
end

class EfcDataset < VctDataset
    def initialize
    end
end

class FciDataset < VctDataset
    def initialize
    end
end

def dataset2file(vctds,vctfile)
    vctfile.head do |f|
        f.puts vctds.srs
    end

    vctfile.feature do |f|
        vctds.layers.each { |i|  f.puts i }
    end

    vctfile.table do |f| 
        vctds.layers.each { |i| f.puts i.field  }
    end

    pointlayers = vctds.layers.select { |i|  i.type == "Point"}
    vctfile.point do |f|
        pointlayers.each do |l|
            l.feats.each do |feat|
                f.puts feat.geometry
            end
        end
    end

    linelayers = vctds.layers.select { |i| i.type == "Line"  }
    vctfile.line do |f|
        linelayers.each do |l|
            l.feats.each do | feat|
                f.puts feat.geometry
            end
        end
    end

    polygonlayers = vctds.layers.select { |i| i.type == "Polygon" }
    vctfile.polygon do |f|
        polygonlayers.each do |l|
            l.feats.each do | feat|
                f.puts feat.geometry
            end
        end
    end

    vctfile.attribute do |f|
        vctds.layers.each do |layer|
            f.puts layer.table
            layer.feats.each do |feat|
                f.puts feat.attribute
            end
            f.puts "TableEnd"
            f.puts 
        end
    end
    
end

def create_ds(name,size)
    vct_ds   = VctDataset.new(name)
    vct_fake = VctCreater.new(vct_ds,size) 
    return vct_ds,vct_fake
end

def fake_vct_efc(vctds,vctfake)
    vctfake.fake_efc
    return vctds,vctfake
end

def fake_vct_fci(vctds,vctfake)
    new_vct_ds = vctds.clone
    vctfake.vct = new_vct_ds
    vctfake.fake_fci
    return new_vct_ds,vctfake
end

def create_file(name)
    return VctFile.new(name)
end

def main(argv)
    size = argv[0] || 2
    name = argv[1] || 'TEST'
    vct_ds,vct_fake  = create_ds(name,size.to_i)

    efc_ds,efc_fake = fake_vct_efc(vct_ds,vct_fake)
    vct_file_efc = create_file("#{name}_efc.VCT")
    dataset2file(vct_ds,vct_file_efc)
    vct_file_efc.close

    fci_ds,fci_fake = fake_vct_fci(efc_ds,efc_fake)
    vct_file_fci = create_file("#{name}_fci.VCT")
    dataset2file(fci_ds,vct_file_fci)
    vct_file_fci.close

end

main(ARGV)