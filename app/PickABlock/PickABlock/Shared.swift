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

  static func setUpSegmentedControl(frame: CGRect, elements: [String], yOffset: CGFloat, isHidden: Bool = false) -> UISegmentedControl {
    let control = UISegmentedControl(items: elements)
    control.layer.borderColor = Defs.DarkRed.cgColor
    control.tintColor = Defs.DarkRed
    control.backgroundColor = Defs.White.withAlphaComponent(0.5)
    control.frame = CGRect(x: frame.minX + 10, y: frame.maxY - yOffset,
                           width: frame.maxX - 20, height: 40)
    control.isHidden = isHidden
    control.layer.cornerRadius = 15.0
    control.layer.borderWidth = 1.0
    control.layer.masksToBounds = true
    control.isMomentary = true

    return control
  }

  static func getTextView(frame: CGRect, placecholder: String) -> UITextView {
    let tv = UITextView(frame: frame)
    tv.font = UIFont.systemFont(ofSize: 15)
    tv.layer.borderColor = Defs.DarkRed.cgColor
    tv.layer.cornerRadius = 15.0
    tv.layer.borderWidth = 1.0
    tv.tintColor = Defs.DarkRed
    tv.keyboardType = UIKeyboardType.default
    tv.returnKeyType = UIReturnKeyType.done
    tv.textContainer.lineBreakMode = .byCharWrapping

    return tv
  }
}

extension UIButton
{
  func setUpLayer(button: UIButton?, displayName: String, x: Int, y: Int, width: Int, height: Int, isEnable: Bool = true) {
    button!.setTitle(displayName, for: .normal)
    button!.setTitleColor(Defs.DarkRed, for: .normal)
    button!.layer.backgroundColor = Defs.White.withAlphaComponent(0.5).cgColor
    button!.layer.borderColor = Defs.DarkRed.cgColor
    button!.frame = CGRect(x: x, y: y, width:width, height:height)
    button!.layer.borderWidth = 1.0
    button!.layer.cornerRadius = 5.0
    button!.isEnabled = isEnabled
  }

  override open var isHighlighted: Bool {
    get {
      return super.isHighlighted
    }
    set {
      if newValue {
        backgroundColor = Defs.DarkRed
        titleLabel?.textColor = Defs.White
      }
      else {
        backgroundColor = Defs.White.withAlphaComponent(0.5)
        titleLabel?.textColor = Defs.DarkRed
      }
      super.isHighlighted = newValue
    }
  }
}
