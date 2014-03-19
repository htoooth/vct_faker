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