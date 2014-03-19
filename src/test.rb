class A
    def pu
        yield(1)
    end

    def x
        puts "adfd"
    end

    def a 
        pu
        x()
    end
end

class B < A
    def pu
        super do |i|
            puts i
        end
    end

    def x
        puts "abcdef"
    end

    
end

b = B.new()
b.a
