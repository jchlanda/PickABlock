#! /usr/bin/env python

import datetime
import sys
import os.path
import re
from svgpathtools import svg2paths


class SvgParser(object):

  def __init__(self, inFileName, outFileName):
    self.counter = 0
    self.inFileName = inFileName
    self.outFileName = outFileName
    if (self.outFileName):
      self.outFile = open(self.outFileName, "a+")
      self.outFile.truncate(0)

  def __exit__(self, *args):
    if (self.outFileName):
      self.outFile.close()

  def output(self, message, needsNewLine = True):
    if self.outFileName:
      self.outFile.write(message)
      if needsNewLine:
        self.outFile.write("\n")
    else:
      sys.stdout.write(message)
      if needsNewLine:
        print("")

  def parse_svg(self):
    self.header()
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

    self.process_common()
    self.process_shapes(shapesCoords)
    self.footer()

  def header(self):
    now = datetime.datetime.now()
    self.output("//")
    self.output("//  ShapesCoords.swift")
    self.output("//  Block")
    self.output("//")
    self.output("//  Created by Jakub on {0}/{1}/{2}.".format(now.day, now.month, now.year))
    self.output("//  Copyright c 2019 Jakub. All rights reserved.")
    self.output("//")
    self.output("//  Auto-generated from svg file, using svgparser.py")
    self.output("//")
    self.output("")
    self.output("class AutoGen {")
    self.output("  struct FromSVG {")
    self.output("    static var ShapesCoords: [[(Double, Double)]] = [")

  def footer(self):
    self.output("  }")
    self.output("}")

  def process_shapes(self, shapes):
    for shape in shapes[:-1]:
      self.output("      [\n       ", False)
      for i, point in enumerate(shape[:-1]):
        point = point.split(",")
        self.output(" ({0}, {1}),".format(point[0], point[1]), False)
        if 0 == (i + 1) % 4 and i:
          self.output("\n       ", False)
      lastPoint = shape[-1].split(",")
      self.output(" ({0}, {1})\n      ],".format(lastPoint[0], lastPoint[1]))
    self.output("      [\n        ", False)
    for i, point in enumerate(shapes[-1][:-1]):
      point = point.split(",")
      self.output("({0}, {1}),".format(point[0], point[1]), False)
      if 0 == (i + 1) % 4 and i:
        self.output("\n        ", False)
    lastPoint = shapes[-1][-1].split(",")
    self.output("({0}, {1})\n      ]".format(lastPoint[0], lastPoint[1]))
    self.output("    ]")

  def process_common(self):
    self.output("//  Intended use:")
    self.output("//  for ShC in AutoGen.FromSVG.ShapesCoords {")
    self.output("//    let Shape = CAShapeLayer()")
    self.output("//    Shapes.append(Shape)")
    self.output("//    let Path = UIBezierPath()")
    self.output("//    Path.move(to: CGPoint(x: ShC[0].0, y: ShC[0].1))")
    self.output("//    for Point in ShC.dropFirst() {")
    self.output("//      Path.addLine(to: CGPoint(x: Point.0, y: Point.1))")
    self.output("//    }")
    self.output("//    Path.close()")
    self.output("//    Paths.append(Path)")
    self.output("//  }")
    self.output("")

    self.output("//  for (Sh, P) in zip(Shapes, Paths) {")
    self.output("//    imageView.layer.addSublayer(Sh)")
    self.output("//    Sh.opacity = 0.5")
    self.output("//    Sh.lineWidth = 2")
    self.output("//    Sh.lineJoin = CAShapeLayerLineJoin.miter")
    self.output(
        "//    Sh.strokeColor = UIColor(hue: 0.786, saturation: 0.79, brightness:"
        "0.53,\n//      alpha: 1.0).cgColor")
    self.output(
        "//    Sh.fillColor = UIColor(hue: 0.786, saturation: 0.15, brightness: "
        "0.89,\n//      alpha: 1.0).cgColor")
    self.output("//    Sh.path = P.cgPath")
    self.output("//  }")

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
