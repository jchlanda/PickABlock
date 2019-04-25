//
//  Shared.swift
//  Block
//
//  Created by Jakub on 16/03/2019.
//  Copyright © 2019 Jakub. All rights reserved.
//

import Foundation
import UIKit

struct ColoredOverlayPath {
  init(index: Int, shapePath: CAShapeLayer) {
    colorArrayIdx = index
    overlayShapePath = shapePath
  }
  var colorArrayIdx: Int
  var overlayShapePath: CAShapeLayer
}


struct Defs {
  // Begin
  static let GreenStroke = UIColor(hue: 0.3694, saturation: 1, brightness: 0.44, alpha: 1.0)
  static let GreenFill = UIColor(hue: 0.3694, saturation: 1, brightness: 0.24, alpha: 1.0)
  // End.
  static let BlueStroke = UIColor(hue: 0.5861, saturation: 1, brightness: 0.71, alpha: 1.0)
  static let BlueFill = UIColor(hue: 0.5861, saturation: 1, brightness: 0.51, alpha: 1.0)
  // Feet only.
  static let YellowStroke = UIColor(hue: 0.1278, saturation: 1, brightness: 1, alpha: 1.0)
  static let YellowFill = UIColor(hue: 0.1278, saturation: 1, brightness: 0.7, alpha: 1.0)
  // Normal.
  static let RedStroke = UIColor(hue: 0, saturation: 1, brightness: 0.85, alpha: 1.0)
  static let RedFill = UIColor(hue: 0, saturation: 1, brightness: 0.55, alpha: 1.0)
  
  static let DarkRed = UIColor(hue: 0, saturation: 1, brightness: 0.63, alpha: 1.0)
  
  static let White = UIColor(hue: 0, saturation: 0, brightness: 1, alpha: 1.0)
  
  static let NoFill = UIColor(hue: 0, saturation: 0, brightness: 0.0, alpha: 0.0)
  
  // RRGGBB hex colors in the same order as the image
  static let colorArray = [ 0x000000, 0xfe0000, 0xff7900, 0xffb900, 0xffde00, 0xfcff00, 0x8c0000, 0x05c000, 0x00c0a7, 0x0600ff, 0x6700bf, 0x9500c0, 0xbf0199, 0xffffff ]
  static func uiColorFromHex(rgbValue: Int) -> UIColor {
    let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 0xFF
    let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 0xFF
    let blue = CGFloat(rgbValue & 0x0000FF) / 0xFF
    let alpha = CGFloat(1.0)
    
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }
}
