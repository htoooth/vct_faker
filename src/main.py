import sys
import os
class Vct:
    def __init__(self, row, fp):
        self.row= row
        if os.path.isfile(fp):
            os.remove(fp)
            print "delete %s" % fp
        self.file = open(fp,"w")

        self.id = 0
        self.layer = {}
        self.pointNum = self.row ^ 2
        self.lineNum = 2*self.row ^2 - 2* self.row
        self.polygonNum = (self.row -1) * (self.row -1)

    def write(self,s):
        self.file.write(s)

    def head(self,body):
        self.write("HeadBegin\n")
        self.write(body);
        self.write("HeadEnd\n\n")

    def feature(self,body):
        self.write("FeatureCodeBegin\n")
        self.write("FeatureCodeEnd\n\n")

    def table(self,body):
        self.write("TableStructureBegin\n")
        self.write("TableStructureEnd\n\n")

    def point(self,body):
        self.write("PointBegin\n")
        self.write("PointEnd\n\n")

    def line(self,body):
        self.write("LineBegin\n")
        self.write("LineEnd\n\n")

    def polygon(self,body):
        self.write("PolygonBegin\n")
        self.write("PolygonEnd\n\n")

    def attribute(self,body):
        self.write("AttributeBegin\n")
        self.write("AttributeEnd\n\n")

    def close(self):
        self.file.close()

    def generate(self):
        self.head("hel")
        self.feature("hel")
        self.table("hel")
        self.point("hel")
        self.line("hel")
        self.polygon("hel")
        self.attribute("hel")
        
if __name__ == "__main__":
    row = 2
    f = "TEST.VCT"
    if len(sys.argv) >1:
        row = sys.argv[1]
        f = sys.argv[2] 

    vct = Vct(row,f)
    vct.generate()
    vct.close()