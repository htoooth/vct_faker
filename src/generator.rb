
class EfcDatasetGenerator < Generator
    def initialize(vctfake,name)
        @vct = VctDataset.new(name)
    end

    def generate()
        return @vct
    end
end

class FciDatasetGenerator < Generator
    def initialize(vctfake,name)
        @vct = VctDataset.new(name)
    end

    def generate()
        return @vct
    end
end

class Generator
    def initialize(vctfake,name)
        @vct = VctDataset.new(name)
    end

    def generate()
        return @vct
    end
end