//
//  BlockProblemManager.swift
//  Block
//
//  Created by Jakub on 12/03/2019.
//  Copyright © 2019 Jakub. All rights reserved.
//

import Foundation
import UIKit

struct OverlayColorPair : Codable {
  init(color: Int, path: [[Int]]) {
    self.color = color
    self.path = path
  }
  init() {
    self.color = 0
    self.path = []
  }
  var color: Int
  var path: [[Int]]

}
extension OverlayColorPair: Equatable {
  static func == (lhs: OverlayColorPair, rhs: OverlayColorPair) -> Bool {
    return lhs.color == rhs.color &&
      lhs.path == rhs.path
  }
}

struct Problem : Codable {
  init() {
    self.name = ""
    self.begin = []
    self.end = []
    self.feetOnly = []
    self.normal = []
    self.overlays = [OverlayColorPair()]
  }
  init(name: String, begin: [Int], end: [Int], feetOnly: [Int], normal: [Int], overlays: [OverlayColorPair]) {
    self.name = name
    self.begin = begin
    self.end = end
    self.feetOnly = feetOnly
    self.normal = normal
    self.overlays = overlays
  }

  var name: String
  var begin: [Int]
  var end: [Int]
  var feetOnly: [Int]
  var normal: [Int]
  var overlays: [OverlayColorPair]
}
extension Problem: Equatable {
  static func == (lhs: Problem, rhs: Problem) -> Bool {
    return lhs.name == rhs.name &&
      lhs.begin == rhs.begin &&
      lhs.end == rhs.end &&
      lhs.feetOnly == rhs.feetOnly &&
      lhs.normal == rhs.normal &&
      lhs.overlays == rhs.overlays
  }
}

enum HoldType {
  case begin
  case end
  case feetOnly
  case normal
  case none
}

struct Sticky {
  var value : HoldType
  init() {
    value = HoldType.none
  }
}

class BlockProblemManager {
  static let shared = BlockProblemManager()

  var stickyToggle: Sticky = Sticky()

  var knownProblems: [Problem] = []
  var knownOverlays: [[CAShapeLayer]] = []
  let knownProblemsFile = Bundle.main.path(forResource: "KnownProblems", ofType: "json")!
  var knownProblemsIdx: Int = 0

  var userLocalStartIdx: Int = 0
  var userLocalFile = URL.documentsURL.appendingPathComponent("UserLocalProblems.json")

  var currentProblem: Problem = Problem()

  init() {
    knownProblems = loadProblemsFromFile(path: knownProblemsFile)
    userLocalStartIdx = knownProblems.count
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: userLocalFile.path) {
      FileManager.default.createFile(atPath: userLocalFile.path, contents: nil, attributes: nil)
    } else {
      knownProblems.append(contentsOf: loadProblemsFromFile(path: userLocalFile.path))
    }

  }

  func loadProblemsFromFile(path: String) -> [Problem] {
    do {
      let contents = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
      if (contents == "") {
        return []
      }
      let data = try Data(contentsOf: URL(fileURLWithPath: path))
      let decoder = JSONDecoder()

      let jsonData = try decoder.decode([Problem].self, from: data)
      return jsonData
    } catch {
      print("error:\(error)")
      return []
    }
  }

  func initKnownOverlays(view: UIImageView) {
    knownOverlays.removeAll()
    for p in self.knownProblems {
      var currentOverlays: [CAShapeLayer] = []
      for o in p.overlays {
        if (o.path.count < 2) {
          continue
        }
        let Shape = CAShapeLayer()
        view.layer.addSublayer(Shape)
        Shape.opacity = 0.5
        Shape.lineWidth = 5
        Shape.lineJoin = CAShapeLayerLineJoin.miter
        Shape.strokeColor = Defs.uiColorFromHex(rgbValue: Defs.colorArray[o.color]).cgColor
        Shape.fillColor = Defs.NoFill.cgColor
        let overlayPath: UIBezierPath = UIBezierPath()
        overlayPath.move(to: CGPoint(x: CGFloat(o.path[0][0]), y: CGFloat(o.path[0][1])))
        for i in 1..<o.path.count {
          overlayPath.addLine(to: CGPoint(x: CGFloat(o.path[i][0]), y: CGFloat(o.path[i][1])))
        }
        Shape.path = overlayPath.cgPath
        Shape.isHidden = true
        currentOverlays.append(Shape)
      }
      knownOverlays.append(currentOverlays)
    }
  }

  // Both inclusive
  func saveUserLocalProblems(path: URL, startIdx: Int, endIdx: Int) {
    let data = serializeProblems(startIdx: startIdx, endIdx: endIdx)
    do {
      try data.write(to: path)
    }
    catch {
      print("error:\(error)")
    }
  }

  // Both inclusive.
  func stringifyProblems(startIdx: Int, endIdx: Int) -> String {
    if (endIdx < startIdx) {
      return ""
    }
    let data = serializeProblems(startIdx: startIdx, endIdx: endIdx)
    return String(data: data, encoding: String.Encoding.utf8)!
  }

  // Both inclusive.
  func serializeProblems(startIdx: Int, endIdx: Int) -> Data {
    do {
      if (endIdx < startIdx) {
        return Data()
      }
      // Can't form a range if start == end.
      return try JSONEncoder().encode(startIdx == endIdx ? [knownProblems[startIdx]] : Array(knownProblems[startIdx...endIdx]))
    }
    catch {
      print("error:\(error)")
      return Data()
    }
  }

  func setSticky(type: HoldType) {
    stickyToggle.value = type
  }

  func displayNextKnownProblem(view: UIImageView, shapes: inout [CAShapeLayer]) {
    clean(oldIdx: knownProblemsIdx, shapes: &shapes)
    if (knownProblemsIdx == knownProblems.count - 1) {
      knownProblemsIdx = 0
    } else {
      knownProblemsIdx += 1
    }
    displayKnownProblem(view: view, problemIdx: knownProblemsIdx, shapes: &shapes)
  }

  func displayPrevKnownProblem(view: UIImageView, shapes: inout [CAShapeLayer]) {
    clean(oldIdx: knownProblemsIdx, shapes: &shapes)
    if (knownProblemsIdx == 0) {
      knownProblemsIdx = knownProblems.count - 1
    } else {
      knownProblemsIdx -= 1
    }
    displayKnownProblem(view: view, problemIdx: knownProblemsIdx, shapes: &shapes)
  }

  func displayKnownProblem(view: UIImageView, problemIdx: Int, shapes: inout [CAShapeLayer]) {
    currentProblem = knownProblems[problemIdx]
    for b in currentProblem.begin {
      displayHold(type: HoldType.begin, hold: &shapes[b])
    }
    for e in currentProblem.end {
      displayHold(type: HoldType.end, hold: &shapes[e])
    }
    for f in currentProblem.feetOnly {
      displayHold(type: HoldType.feetOnly, hold: &shapes[f])
    }
    for n in currentProblem.normal {
      displayHold(type: HoldType.normal, hold: &shapes[n])
    }
    for o in knownOverlays[problemIdx] {
      o.isHidden = false
    }
  }

  func getKnownProblemIdx() -> Int {
    return knownProblemsIdx
  }

  func getUserLocalStartIdx() -> Int {
    return userLocalStartIdx
  }

  func getNumKnownProblems() -> Int {
    return knownProblems.count
  }

  func hasUserLocalProblems() -> Bool {
    return userLocalStartIdx < knownProblems.count
  }

  func displayHold(type: HoldType, hold: inout CAShapeLayer) {
    hold.opacity = 0.5
    hold.fillColor = Defs.White.cgColor
    switch type {
    case HoldType.begin:
      hold.strokeColor = Defs.GreenStroke.cgColor
    case HoldType.end:
      hold.strokeColor = Defs.BlueStroke.cgColor
    case HoldType.feetOnly:
      hold.strokeColor = Defs.YellowStroke.cgColor
    case HoldType.normal:
      hold.strokeColor = Defs.RedStroke.cgColor
    default:
      hold.strokeColor = Defs.RedStroke.cgColor
      hold.opacity = 0
    }
  }

  func remove(index: Int, hold: inout CAShapeLayer) {
    hold.strokeColor = Defs.RedStroke.cgColor
    hold.fillColor = Defs.White.cgColor
    hold.opacity = 0
    if let i = currentProblem.normal.firstIndex(of: index) {
      currentProblem.normal.remove(at: i)
      return
    }
    if let i = currentProblem.begin.firstIndex(of: index) {
      currentProblem.begin.remove(at: i)
      return
    }
    if let i = currentProblem.end.firstIndex(of: index) {
      currentProblem.end.remove(at: i)
      return
    }
    if let i = currentProblem.feetOnly.firstIndex(of: index) {
      currentProblem.feetOnly.remove(at: i)
      return
    }
  }

  func containsProblem(problem: Problem, array: ArraySlice<Problem>) -> Int {
    for (idx, p) in array.enumerated() {
      if (p == problem) {
        return idx
      }
    }
    return -1
  }

  func addManually(problems: String) -> String {
    do {
      let decoder = JSONDecoder()
      let data = Data(problems.utf8)
      let manualProblems = try decoder.decode([Problem].self, from: data)
      var appended = 0
      for p in manualProblems {
        if (-1 == containsProblem(problem: p, array: knownProblems[0...knownProblems.count - 1])) {
          knownProblems.append(p)
          appended += 1
        }
      }
      if (appended > 0) {
        saveUserLocalProblems(path: userLocalFile, startIdx: userLocalStartIdx, endIdx: knownProblems.count - 1)
        var message = "Added " + String(appended) + " new problem"
        if (appended > 1) {
          message += "s."
        } else {
          message += "."
        }
        return message
      } else {
        return "No new problems appended."
      }
    } catch {
      return error.localizedDescription
    }
  }

  // Assumes there are no duplicates in built in problems.
  func purgeDuplicates() -> Int {
    var toDelete: [Int] = []
    if (userLocalStartIdx == knownProblems.count) {
      return 0
    }
    // Check if udp duplicates bip.
    for (idx, p) in knownProblems[userLocalStartIdx...knownProblems.count - 1].enumerated() {
      for knownP in knownProblems[0...userLocalStartIdx - 1] {
        if (p == knownP) {
          toDelete.append(idx + userLocalStartIdx)
        }
      }
    }
    // Check if there are duplicates in udps.
    if (userLocalStartIdx < knownProblems.count - 1) {
      for (idx, p) in knownProblems[userLocalStartIdx...knownProblems.count - 2].enumerated() {
        for newP in knownProblems[idx + userLocalStartIdx + 1...knownProblems.count - 1] {
          if (p == newP) {
            toDelete.append(idx + userLocalStartIdx)
          }
        }
      }
    }
    if (toDelete.count == 0) {
      return 0
    }

    toDelete.sort()
    for idx in toDelete.reversed() {
      knownProblems.remove(at: idx)
    }
    knownProblemsIdx = 0
    saveUserLocalProblems(path: userLocalFile, startIdx: userLocalStartIdx, endIdx: knownProblems.count - 1)

    return toDelete.count
  }

  func add(index: Int, hold: inout CAShapeLayer, type: HoldType, isSticky: Bool) {
    var currType = type
    if (isSticky) {
      currType = stickyToggle.value
    }
    switch currType {
    case HoldType.normal:
      if currentProblem.normal.firstIndex(of: index) != nil {
        return
      }
      currentProblem.normal.append(index)
    case HoldType.begin:
      if currentProblem.begin.firstIndex(of: index) != nil {
        return
      }
      currentProblem.begin.append(index)
    case HoldType.end:
      if currentProblem.end.firstIndex(of: index) != nil {
        return
      }
      currentProblem.end.append(index)
    case HoldType.feetOnly:
      if currentProblem.feetOnly.firstIndex(of: index) != nil {
        return
      }
      currentProblem.feetOnly.append(index)
    default:
      return
    }
    displayHold(type: currType, hold: &hold)
  }

  func getKnownProblemName() -> String {
    return knownProblems[knownProblemsIdx].name
  }

  func consumeColoredOverlayPaths(problem: inout Problem, overlayShapePath: [ColoredOverlayPath]) {
    for o in overlayShapePath {
      var path: [[Int]] = []
      for p in o.overlayShapePath.path!.points {
        path.append([Int(p.x), Int(p.y)])
      }
      problem.overlays.append(OverlayColorPair(color: o.colorArrayIdx, path: path))
    }
  }

  func serialize(name: String, overlays: [ColoredOverlayPath]) {
    currentProblem.name = name
    consumeColoredOverlayPaths(problem: &currentProblem, overlayShapePath: overlays)
    knownProblems.append(currentProblem)
    saveUserLocalProblems(path: userLocalFile, startIdx: userLocalStartIdx, endIdx: knownProblems.count - 1)
  }

  func clean(oldIdx: Int, shapes: inout [CAShapeLayer]) {
    for b in currentProblem.begin {
      shapes[b].opacity = 0
      shapes[b].strokeColor = Defs.RedStroke.cgColor
      shapes[b].fillColor = Defs.White.cgColor
    }
    for e in currentProblem.end {
      shapes[e].opacity = 0
      shapes[e].strokeColor = Defs.RedStroke.cgColor
      shapes[e].fillColor = Defs.White.cgColor
    }
    for n in currentProblem.normal {
      shapes[n].opacity = 0
      shapes[n].strokeColor = Defs.RedStroke.cgColor
      shapes[n].fillColor = Defs.White.cgColor
    }
    for f in currentProblem.feetOnly {
      shapes[f].opacity = 0
      shapes[f].strokeColor = Defs.RedStroke.cgColor
      shapes[f].fillColor = Defs.White.cgColor
    }
    currentProblem = Problem()
    for o in knownOverlays[oldIdx] {
      o.isHidden = true
    }
  }

  func canDeleteProblem() -> Bool {
    return knownProblemsIdx >= userLocalStartIdx
  }

  func deleteProblem() {
    if let idx = knownProblems.firstIndex(where: { $0 == currentProblem }) {
      knownProblems.remove(at: idx)
      // No more user local problems, clear the file.
      if (knownProblems.count >= userLocalStartIdx) {
        do {
          try Data().write(to: userLocalFile)
        } catch {
          print(error)
          return
        }
      } else {
        saveUserLocalProblems(path: userLocalFile, startIdx: userLocalStartIdx, endIdx: knownProblems.count - 1)
      }
      for o in knownOverlays[idx] {
        o.isHidden = true
      }
      knownOverlays.remove(at: idx)
      if (knownProblemsIdx > 0) {
        knownProblemsIdx -= 1
      }
      else {
        knownProblemsIdx = knownProblems.count - 1
      }
    }
  }
}

extension URL {
  static var documentsURL: URL {
    return try! FileManager
      .default
      .url(for: .documentDirectory,
           in: .userDomainMask,
           appropriateFor: nil,
           create: true)
  }
}
