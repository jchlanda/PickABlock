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
    self.created = ""
    self.begin = []
    self.end = []
    self.feetOnly = []
    self.normal = []
    self.overlays = [OverlayColorPair()]
  }
  init(name: String, created: String, begin: [Int], end: [Int], feetOnly: [Int], normal: [Int], overlays: [OverlayColorPair]) {
    self.name = name
    self.created = created
    self.begin = begin
    self.end = end
    self.feetOnly = feetOnly
    self.normal = normal
    self.overlays = overlays
  }

  // Swift hashValue is not deterministic and so can't be used across multiple execution of a program.
  // Hash name + created + normal holds.
  func hashValue() -> UInt64 {
    var result = UInt64(5381)
    let buf = [UInt8]((name + created).utf8)
    for b in buf {
      result = 127 * (result & 0x00ffffffffffffff) + UInt64(b)
    }
    for n in normal {
      result = 127 * (result & 0x00ffffffffffffff) + UInt64(n)
    }
    return result
  }

  var name: String
  var created: String
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
  let knownProblemsFile = Bundle.main.path(forResource: "PickABlockKnownProblems", ofType: "json")!
  var knownProblemsIdx: Int = 0

  var userLocalStartIdx: Int = 0
  var userLocalFile = URL.documentsURL.appendingPathComponent("PickABlockUserLocalProblems.json")

  var infoLocalFile = URL.documentsURL.appendingPathComponent("PickABlockProblemsInfo.json")
  var knownProblemsInfo: [UInt64 : String] = [:]

  var currentProblem: Problem = Problem()

  let decoder = JSONDecoder()

  init() {
    knownProblems = loadProblemsFromFile(path: knownProblemsFile)
    userLocalStartIdx = knownProblems.count
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: userLocalFile.path) {
      FileManager.default.createFile(atPath: userLocalFile.path, contents: nil, attributes: nil)
    } else {
      knownProblems.append(contentsOf: loadProblemsFromFile(path: userLocalFile.path))
    }
    if !fileManager.fileExists(atPath: infoLocalFile.path) {
      FileManager.default.createFile(atPath: infoLocalFile.path, contents: nil, attributes: nil)
    } else {
      knownProblemsInfo = loadProblemsInfoFromFile(path: infoLocalFile.path)
    }
  }

  func loadProblemsFromFile(path: String) -> [Problem] {
    do {
      let contents = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
      if (contents == "") {
        return []
      }
      let data = try Data(contentsOf: URL(fileURLWithPath: path))
      let jsonData = try decoder.decode([Problem].self, from: data)
      return jsonData
    } catch {
      print("error:\(error)")
      return []
    }
  }

  func loadProblemsInfoFromFile(path: String) -> [UInt64:String] {
    do {
      let contents = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
      if (contents == "") {
        return [:]
      }
      let data = try Data(contentsOf: URL(fileURLWithPath: path))
      let jsonData = try decoder.decode([UInt64:String].self, from: data)
      return jsonData
    } catch {
      print("error:\(error)")
      return [:]
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
        Shape.lineWidth = 18.0
        Shape.lineJoin = CAShapeLayerLineJoin.miter
        Shape.strokeColor = Defs.uiColorFromHex(rgbValue: Defs.colorArray[o.color]).cgColor
        Shape.fillColor = Defs.NoFill.cgColor
        let overlayPath: UIBezierPath = UIBezierPath()
        overlayPath.lineWidth = 18.0
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
      print("error:\n(error)")
    }
  }

  // Both inclusive.
  func stringifyProblems(startIdx: Int, endIdx: Int) -> String {
    if (endIdx < startIdx) {
      return "[]"
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
    hold.lineWidth = 16.0
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

  func updateAll(info: String) -> String {
    var addedProblems = false
    var addedInfo = false
    let lines = info.split { $0.isNewline }
    for (idx, line) in lines.enumerated() {
      if (line == "Build In Problems:") {
        if ("No new problems appended." != addManually(problems: String(lines[idx + 1]))) {
          addedProblems = true
        }
      } else if (line == "User Local Problems:") {
        if ("No new problems appended." != addManually(problems: String(lines[idx + 1]))) {
          addedProblems = true
        }
      } else if (line == "Problems Info:") {
        if (String(lines[idx + 1]) != "[]") {
          _ = updateProblemInfo(info: String(lines[idx + 1]))
          addedInfo = true
        }
      }
    }

    var message = ""
    if (addedProblems && addedInfo) {
      message = "Added new problems and problems info."
    } else if (addedProblems) {
      message = "Added new problems."
    } else if (addedInfo) {
      message = "Added problems info."
    } else {
      message = "No new information found."
    }

    return message
  }

  func addManually(problems: String) -> String {
    do {
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

  func updateProblemInfo(info: String) -> String {
    let data = Data(info.utf8)
    do {
      _ = try decoder.decode([UInt64:String].self, from: data)
    } catch {
      return "Error: The given data was not valid JSON."
    }
    saveProblemsInfo(path: infoLocalFile, data: data)
    knownProblemsInfo = loadProblemsInfoFromFile(path: infoLocalFile.path)
    return "Problem info updated successfully."
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

  func setCreated() {
    currentProblem.created = getTimeStamp()
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

  // Like for Problems, provide 3 steps:
  // - serialize - produces data,
  // - stringify - takes data, returns string,
  // - write - takes data and puts it to a file.
  func saveProblemsInfo(path: URL, data: Data) {
    do {
      try data.write(to: path)
    } catch {
      print("error:\n(error)")
    }
  }

  func stringifyProblemsInfo() -> String {
    let data = serializeProblemsInfo()
    return String(data: data, encoding: String.Encoding.utf8)!
  }

  func serializeProblemsInfo() -> Data {
    do {
      return try JSONEncoder().encode(knownProblemsInfo)
    } catch {
      print("error:\n(error)")
      return Data()
    }
  }

  func getKnownProblemInfo() -> String {
    let hash = knownProblems[knownProblemsIdx].hashValue()
    var info = "created: " + knownProblems[knownProblemsIdx].created
    if let notes = knownProblemsInfo[hash] {
      info += "\n\nnotes:\n" + notes
    }
    return info
  }

  func addKnownProblemInfo(info: String) {
    let hash = knownProblems[knownProblemsIdx].hashValue()
    if var notes = knownProblemsInfo[hash] {
      notes += "\n" + info
      knownProblemsInfo[hash] = notes
    } else {
      knownProblemsInfo[hash] = info
    }
    let data = serializeProblemsInfo()
    saveProblemsInfo(path: infoLocalFile, data: data)
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
    if (knownOverlays.count == 0) {
      return
    }
    for o in knownOverlays[oldIdx] {
      o.isHidden = true
    }
  }

  func isUserDefined() -> Bool {
    return knownProblemsIdx >= userLocalStartIdx
  }

  func deleteCurrentProblem() {
    if let idx = knownProblems.firstIndex(where: { $0 == currentProblem }) {
      deleteProblemAtIdx(idx: idx)
    }
  }

  func deleteProblemAtIdx(idx: Int) {
    // Check if problem has info
    let hash = knownProblems[idx].hashValue()
    if knownProblemsInfo[hash] != nil {
      knownProblemsInfo.removeValue(forKey: hash)
      let data = serializeProblemsInfo()
      saveProblemsInfo(path: infoLocalFile, data: data)
    }
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

  func getTimeStamp() -> String {
    let date = Date()
    let calendar = Calendar.current
    let day = calendar.component(.day, from: date)
    let month = calendar.component(.month, from: date)
    let year = calendar.component(.year, from: date)
    let hour = calendar.component(.hour, from: date)
    let minutes = calendar.component(.minute, from: date)

    let romanMonth: String
    switch month {
    case 1: romanMonth = "I"
    case 2: romanMonth = "II"
    case 3: romanMonth = "III"
    case 4: romanMonth = "IV"
    case 5: romanMonth = "V"
    case 6: romanMonth = "VI"
    case 7: romanMonth = "VII"
    case 8: romanMonth = "VIII"
    case 9: romanMonth = "IX"
    case 10: romanMonth = "X"
    case 11: romanMonth = "XI"
    case 12: romanMonth = "XII"
    default: romanMonth = "Roman literals, eh!"
    }

    var minutesString = String(minutes)
    if (minutes < 10) {
      minutesString = "0\(minutesString)"
    }
    return String(day) + " " + String(romanMonth) + " " + String(year) + "  " + String(hour) + ":" + minutesString
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
