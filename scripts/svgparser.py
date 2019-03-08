#! /usr/bin/env python

import sys
import os.path
import re
from svgpathtools import svg2paths


class SvgParser(object):

  counter = 1

  def parse_svg(self, fileName):
    shapesCoords = []
    paths, attributes = svg2paths(sys.argv[1])
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

    return shapesCoords

  def print_shape(self, shape):
    if len(shape) < 2:
      return
    shapeName = "shape{0}".format(self.counter)
    pathName = "path{0}".format(self.counter)
    self.counter += 1
    print("imageView.layer.addSublayer({0})".format(shapeName))
    print("{0}.opacity = 0.5".format(shapeName))
    print("{0}.lineWidth = 2".format(shapeName))
    print("{0}.lineJoin = CAShapeLayerLineJoin.miter".format(shapeName))
    print("{0}.strokeColor = UIColor(hue: 0.786, saturation: 0.79, brightness: "
          "0.53, alpha: 1.0).cgColor".format(shapeName))
    print("{0}.fillColor = UIColor(hue: 0.786, saturation: 0.15, brightness: "
          "0.89, alpha: 1.0).cgColor".format(shapeName))
    firstPoint = shape[0].split(",")
    print("{0}.move(to: CGPoint(x: {1}, y: {2}))".format(
        pathName, firstPoint[0], firstPoint[1]))
    for point in shape[2:]:
      point = point.split(",")
      print("{0}.addLine(to: CGPoint(x: {1}, y: {2}))".format(
          pathName, point[0], point[1]))
    print("{0}.close()".format(pathName))
    print("{0}.path = {1}.cgPath".format(shapeName, pathName))
    print("")

def main():
  if len(sys.argv) != 2:
    print("Usage: svgparser <input_file>\n")
    return
  fileName = sys.argv[1]
  if not os.path.exists(fileName):
    print("Input file \"{0}\" does not exist.\n".format(fileName))
    return

  SP = SvgParser()
  shapes = SP.parse_svg(fileName)
  print(shapes)
  for s in shapes:
    SP.print_shape(s)

if __name__ == "__main__":
  main()
