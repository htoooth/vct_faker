class Vct
    def initialize(rows,columns,fileName) 
        @rows = rows
        @columns = columns
        if File.exist? fileName
            puts "#{fileName} is exist. Now delete!" 
            File.delete fileName
        end
        @file = File.new(fileName,"w")
        @geobody = File.new("body", "w")
        @headbody = File.new("head","w")

        @id = 0
        @layer = {}
        @layerName = 'layer%<num>d'
        @layerId = '%<id>d'
        @TableName = 'table%<num>d'

        @pointNum = @rows * @columns
        @lineNum = 2*@columns*@rows - (@columns + @rows)
        @polygonNum = (@columns -1) * (@rows -1)

        @point_range_id = (1..@pointNum)
        @line_range_id = ((@pointNum +1)..(@pointNum + @lineNum))
        @polygon_ragne_id = ((@pointNum+ @lineNum +1)..(@pointNum + @lineNum + @polygonNum))
    end

    def head(text)
        @geobody.puts 'HeadBegin'
        yield @geobody,text
        @geobody.puts 'HeadEnd'
        @geobody.puts
    end

    def feature(text)
        text.each do |i|
            id,name,type,*rest,table=i.split(",")
            @layer[id.to_sym] = [id,name,type,table]
        end

        @geobody.puts 'FeatureCodeBegin'
        yield @geobody,text
        @geobody.puts 'FeatureCodeEnd'
        @geobody.puts
    end

    def table(text)
        text.each do |i|
            table = []
            tableType,*fieldType= i.split("\n")
            tableName, = tableType.split(",")
            fieldType.each do |i|
                field = i.split(",")
                if field.size < 4
                    field << 0
                    field << 0
                end

                n,t,w,p = field
                table << FieldType.new(n,t,w,p)
            end

            findLayer = @layer.select do |key,value| 
                value.include? tableName 
            end

            puts "layer is not find" if findLayer == {} 

            findLayer.each do |key,value|
                value << table
            end

        end

        @geobody.puts 'TableStructureBegin'
        yield @geobody,text,@layer
        @geobody.puts 'TableStructureEnd'
        @geobody.puts
    end

    def point(text)
        @geobody.puts 'PointBegin'

        pointLayer = @layer["1001".to_sym]

        @rows.times do |row|  
            @columns.times do |colu|
                @id = @id + 1
                point = Point.new(row,colu)
                pointObj =  {:id=>@id,
                            :layerid=>pointLayer[0],
                            :layername=>pointLayer[1],
                            :num=>1,
                            :point=>point.to_s}
                yield @geobody,text,pointObj
            end
        end
        @geobody.puts 'PointEnd'
        @geobody.puts
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

    def line(text)
        @geobody.puts 'LineBegin'
        lineLayer = @layer["2001".to_sym]
        n = @rows

        (1..@lineNum).each do |l|
            pstart =nil
            pend = nil
            num = rand(1..10)
            if (l-1)%(2*n-1) < (n -1)
                i = (l-1)/(2*n -1)
                j = (l-1)%(2*n -1)
                pstart = Point.new(i,j)
                pend = Point.new(i,j+1)
            elsif (l-1)%(2*n -1) >= (n-1)
                i = (l-1)/(2*n -1)
                j = (l-n)%(2*n -1)
                pstart = Point.new(i,j)
                pend = Point.new(i+1,j)
            else
                next
            end
            p pstart
            p '======'
            p pend
            p '=============='
            points = generateLinePoint(pstart,pend,num)
            @id = @id + 1
            lineObj = {:id=>@id,
                        :layerid=>lineLayer[0],
                        :layername=>lineLayer[1],
                        :type=>1,
                        :num=>num+2,
                        :point=>points.join("\n")}
            yield @geobody,text,lineObj 
        end 

        @geobody.puts 'LineEnd'
        @geobody.puts
    end

    def polygon(text)
        n = @rows

        polygonLayer = @layer["3001".to_sym]
        @geobody.puts 'PolygonBegin'

        (1..@polygonNum).each do |k|

            l1 = (k-1)/(n-1)*(2*n-1) + (k-1)%(n-1) +1
            l2 = l1+n
            l3 = l1+2*n-1 
            l4 = l1+n-1 

            @id = @id + 1

            polygon = {
                :id => @id,
                :layerid => polygonLayer[0],
                :layername => polygonLayer[1],
                :point => '2424,324244',
                :num => 4,
                :line => "#{l1+@pointNum},#{l2+@pointNum},-#{l3+@pointNum},-#{l4+@pointNum}"
            } 
            yield @geobody,text,polygon
        end

        @geobody.puts 'PolygonEnd'
        @geobody.puts
    end

    def attribute(text)

        @geobody.puts 'AttributeBegin'
        @geobody.puts
        #attribute generate and must geometry num

        pointLayer = @layer["1001".to_sym]
        @geobody.puts pointLayer[3]
        generateAttribute(@geobody,(1..@pointNum),pointLayer)
        @geobody.puts 'TableEnd'
        @geobody.puts 

        lineLayer = @layer["2001".to_sym]
        @geobody.puts lineLayer[3]
        generateAttribute(@geobody,((@pointNum+1)..(@lineNum+@pointNum)),lineLayer)
        @geobody.puts 'TableEnd'
        @geobody.puts 

        polygonLayer = @layer["3001".to_sym]
        @geobody.puts polygonLayer[3]
        generateAttribute(@geobody,((@pointNum + @lineNum +1)..(@pointNum+@lineNum+@polygonNum)),polygonLayer)
        @geobody.puts 'TableEnd'
        @geobody.puts 
        @geobody.puts 'AttributeEnd'
    end

    def close
        @geobody.close
    end

    def generateAttribute(file,range,layerdefn)
        layerid = layerdefn[0]
        fieldType = layerdefn[4]
        range.each do |n|
            value = []
            bsm = n
            value << [n,layerid]
            fieldType.each do |t|
                name = t.name
                type = t.type
                width = t.width
                precision = t.precision

                if name == 'BSM' or name == 'YSDM'
                   next 
                end

                val = nil

                case type
                when 'Integer'
                    val = rand(10000)
                when 'Char'
                    val = (0...width.to_i).map { ('a'..'z').to_a[rand(26)] }.join
                when 'Float'
                    val = rand Math::E..Math::PI 
                when 'Varbin'
                    val = (0...20).map { ('a'..'z').to_a[rand(26)] }.join
                end

                value << val
            end
            file.puts value.join(',')
        end
    end
end

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

class Layer
    attr_accessor :id,:name,:type,:table,:field,:fidlist
    def initialize(id,name,type,table,field)
        @id = id
        @name = name
        @type = type
        @table = table
        @field = field
        @fidlist = []
    end

    def to_s
        "#{@id},#{@name},#{@type},0,0,0,#{@table}"
    end
#########################################

r = ARGV[0] || 2
filename = ARGV[1] || 'TEST.VCT'

vct = Vct.new r.to_i,r.to_i,filename

#########################################

headstring =<<-HERE
Datamark: LANDUSE.VCT
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

vct.head headstring do |file,body|
    file.puts body
end

#########################################

layer = [
    '1001,lxdw,Point,0,0,0,lxdwT',
    '2001,xzqjx,Line,0,0,0,xzqjxT',
    '3001,xzq,Polygon,0,0,0,xzqT'
]

vct.feature layer do |file,body|
    body.each {|i| file.puts i }
end

#########################################

lxdwT = <<-HERE
lxdwT,16
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

xzqjxT = <<-HERE
xzqjxT,18
BSM,Integer,10
YSDM,Char,10
KZDMC,Char,50
KZDDH,Char,10
KZDLX,Char,10
KZDDJ,Char,30
DZJ,Varbin
DWYX,Varbin
DWZP,Varbin
X80,Float,10,2
Y80,Float,10,2
Z80,Float,10,2
X54,Float,10,2
Y54,Float,10,2
Z54,Float,10,2
X84,Float,10,2
Y84,Float,10,2
Z84,Float,10,2
HERE

xzqT = <<-HERE
xzqT,7
BSM,Integer,10
YSDM,Char,10
XZQDM,Char,12
XZQMC,Char,100
KZMJ,Float,15,2
JSMJ,Float,15,2
MSSM,Char,2
JXLX,Char,6
JXXZ,Char,6
JXSM,Char,100
HERE

table = [lxdwT,xzqjxT,xzqT]

vct.table table do |file,body|
    table.each {|i| file.puts i}
end

#########################################

pointFormat = <<-HERE
%<id>d
%<layerid>s
%<layername>s
%<num>d
%<point>s
HERE

vct.point pointFormat do |file,body,point|
    printf(file,body,point)
end

#########################################

lineFormat = <<HERE
%<id>d
%<layerid>s
%<layername>s
%<type>s
%<num>d
%<point>s
HERE

vct.line lineFormat do |file,body,line|
   printf(file,body,line)
end

#########################################
polygonFormat = <<HERE
%<id>d
%<layerid>s
%<layername>s
%<point>s
%<num>d
%<line>s
HERE

vct.polygon polygonFormat do |file,body,polygon|
    printf(file,body,polygon)

end

#########################################

vct.attribute 'attribute' 

#########################################


vct.close



