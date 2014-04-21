module Vct
    module Geometry

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
                @points = []
                @start_point = start_point
                @end_point = end_point
                @num = num
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

            def populate()

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
    end
end