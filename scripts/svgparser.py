#! /usr/bin/env python

import sys
import os.path
import re
from svgpathtools import svg2paths


class SvgParser(object):

  def __init__(self, inFileName, outFileName):
    self.counter = 1
    self.inFileName = inFileName
    self.outFileName = outFileName
    if (self.outFileName):
      self.outFile = open(self.outFileName, "a+")
      self.outFile.truncate(0)

  def __exit__(self, *args):
    if (self.outFileName):
      self.outFile.close()

  def output(self, message):
    if self.outFileName:
      self.outFile.write(message)
      self.outFile.write("\n")
    else:
      print(message)

  def parse_svg(self):
    shapesCoords = []
    paths, attributes = svg2paths(self.inFileName)
    dAttribute = attributes[0]['d']
    dAttribute = re.sub(r"\s*[0-9]*\.[0-9]*,[0-9]*\.[0-9]*\s*C", "", dAttribute)
    dAttribute = re.sub(r"\s*Z", "", dAttribute)
    dAttribute = re.sub(r"              ", "DD", dAttribute)

    shapes = filter(None, dAttribute.split("M"))
    for sh in shapes:
      shapeCoord = []
      for s in sh.split("DD"):
        points = list(filter(None, s.split(" ")))
        shapeCoord.append(points[0])
      shapesCoords.append(shapeCoord)

    for s in shapesCoords:
      self.process_shape(s)

  def process_shape(self, shape):
    if len(shape) < 2:
      return
    shapeName = "shape{0}".format(self.counter)
    pathName = "path{0}".format(self.counter)
    self.counter += 1
    self.output("imageView.layer.addSublayer({0})".format(shapeName))
    self.output("{0}.opacity = 0.5".format(shapeName))
    self.output("{0}.lineWidth = 2".format(shapeName))
    self.output("{0}.lineJoin = CAShapeLayerLineJoin.miter".format(shapeName))
    self.output(
        "{0}.strokeColor = UIColor(hue: 0.786, saturation: 0.79, brightness: "
        "0.53, alpha: 1.0).cgColor".format(shapeName))
    self.output(
        "{0}.fillColor = UIColor(hue: 0.786, saturation: 0.15, brightness: "
        "0.89, alpha: 1.0).cgColor".format(shapeName))
    firstPoint = shape[0].split(",")
    self.output("{0}.move(to: CGPoint(x: {1}, y: {2}))".format(
        pathName, firstPoint[0], firstPoint[1]))
    for point in shape[2:]:
      point = point.split(",")
      self.output("{0}.addLine(to: CGPoint(x: {1}, y: {2}))".format(
          pathName, point[0], point[1]))
    self.output("{0}.close()".format(pathName))
    self.output("{0}.path = {1}.cgPath".format(shapeName, pathName))
    self.output("")


def main():
  if len(sys.argv) < 2 and len(sys.argv) < 3:
    print("Usage: svgparser <input_file> <output_file>\n")
    print("       output_file is optional,"
          "       if not set, result is printed to std I\O.\n")
    return
  inFile = sys.argv[1]
  if not os.path.exists(inFile):
    print("Input file \"{0}\" does not exist.\n".format(inFile))
    return
  outFile = None
  if len(sys.argv) == 3:
    outFile = sys.argv[2]

  SP = SvgParser(inFile, outFile)
  SP.parse_svg()


if __name__ == "__main__":
  main()
