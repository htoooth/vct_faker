require_relative 'vctgeometry'

class VctCreator
    attr_accessor :table_define
    attr_accessor :attribute_value
    attr_accessor :srs
    def initialize(size,linerange)
        @pointNum = size ** 2
        @lineNum =  2 * size ** 2 - 2*size
        @polygonNum = (size - 1) ** 2
        @n = size
        @feature_count = @pointNum + @lineNum + @polygonNum

        @srs = nil
        @attribute_value = []
        @table_define = Table.new("test")
        @linerange = linerange

        fake_begin()

        puts "=========creator start at #{Time::now}==========="
        puts "This work create geometry:"
        puts "Point num is #{@pointNum}."
        puts "Line num is #{@lineNum}."
        puts "Polygon num is #{@polygonNum}."
        puts '================================='
    end

    def getLineMax()
        @linerange.end
    end

    def getLinMin()
        @linerange.begin
    end

    def getCount
        @feature_count
    end

    def getPointCount
        @pointNum
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
            @table_define.create_field(n,t,w,p)
        end
    end

    def fake_attribute
        @attribute_value = ["xxmc","iwea","zjfda",
                "vlfda","et","md","rhw","fhc",
                2.9,3.2,2.2,
                4.5,3.2,2.1]
    end

    def each_point
        puts "start fake point."
        (1..@pointNum).each do |p|
            objectid = p
            i = (p - 1) / @n
            j = (p - 1) % @n
            point = Point.new(i,j)
            point.objectid = objectid
            yield(point)
        end
        puts "end fake point."
    end

    def each_line
        puts "start fake line."
        id = @pointNum
        (1..@lineNum).each do |l|
            objectid = id + l
            pointNum = rand(@linerange)
            start_point,end_point = calculate_line_point(l)
            line = Line.new(start_point,end_point,pointNum)
            line.objectid = objectid
            yield(line)
        end
        puts "end fake line."
    end

    def each_polygon
        puts "start fake polygon."
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
            polygon.objectid = objectid

            yield(polygon)
        end
        puts "end fake polygon."
    end

    def fake_begin
        fake_head()
        fake_table_structure()
        fake_attribute()
    end

end