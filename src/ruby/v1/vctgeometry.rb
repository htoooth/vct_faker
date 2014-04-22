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

class Line
    attr_accessor :objectid
    def initialize(start_point,end_point,num)
        @start_point = start_point
        @end_point = end_point
        @num = num
    end

    def size
        @num + 2
    end

    def to_s
        points = []

        points << @start_point

        width = (@end_point.x - @start_point.x).to_f/(@num + 1)
        heigh =  (@end_point.y - @start_point.y).to_f/(@num + 1)
        @num.times do |n|
            point = Point.new(@start_point.x + width*(n+1),@start_point.y + heigh*(n+1))
            points << point
        end

        points << @end_point

        points.join("\n")
    end
end

class Polygon
    attr_accessor :objectid,:size
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
