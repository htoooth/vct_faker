class Vct
    def initialize(rows,columns,fileName) 
        @rows = rows
        @columns = columns
        if File.exist? fileName
            puts "#{fileName} is exist. Now delete!" 
            File.delete fileName
        end
        @file = File.new(fileName, "w")

        @id = 0
        @layer = {}
    end

    def head(text)
        @file.puts 'HeadBegin'
        yield @file,text
        @file.puts 'HeadEnd'
        @file.puts
    end

    def feature(text)
        text.each do |i|
            id,name,type,*rest,table=i.split(",")
            @layer[id.to_sym] = [name,type,table]
        end

        @file.puts 'FeatureCodeBegin'

        yield @file,text
        @file.puts 'FeatureCodeEnd'
        @file.puts
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

        @file.puts 'TableStructureBegin'
        yield @file,text,@layer
        @file.puts 'TableStructureEnd'
        @file.puts
    end

    def point(text)
        @file.puts 'PointBegin'
        yield @file,text
    @file.puts 'PointEnd'
        @file.puts
    end

    def line(text)
        @file.puts 'LineBegin'
        yield @file,text
        @file.puts 'LineEnd'
        @file.puts
    end

    def polygon(text)
        @file.puts 'PolygonBegin'
        yield @file,text
        @file.puts 'PolygonEnd'
        @file.puts
    end

    def attribute(text)
        @file.puts 'AttributeBegin'
        yield @file,text
        @file.puts 'AttributeEnd'
    end

    def close
        @file.close
    end

end

class FieldType
    attr_accessor :name,:type,:width,:precision
    def initialize(name,type,width,precision)
        @name = name
        @type = type
        @with = width
        @precision = precision
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

#########################################

filename = 'TEST.VCT'

vct = Vct.new 1000,1000,filename

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

pointFormat = <<HERE
%d
%s
%s
%d
%s
end
HERE

vct.point pointFormat do |file,body|
    file.puts body

end

#########################################


vct.line 'line' do |file,body|
    file.puts body

end

#########################################
vct.polygon 'polygon' do |file,body|
    file.puts body

end

#########################################
vct.attribute 'attribute' do |file,body|
    file.puts body

end

#########################################


vct.close



