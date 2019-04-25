//
//  BlockProblem.swift
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

struct KnownProblems : Codable {
    var knownProblems: [Problem]
}

struct UserLocalProblems : Codable {
    init() {
        self.userLocalProblems = []
    }
    var userLocalProblems: [Problem]
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
            lhs.normal == rhs.normal
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

class BlockProblem {
    var stickyToggle: Sticky = Sticky()

    var knownProblems: [Problem] = []
    var knownOverlays: [[CAShapeLayer]] = []
    let knownProblemsFile = Bundle.main.path(forResource: "KnownProblems", ofType: "json")!
    var knownProblemsIdx: Int = 0
    var ulp: UserLocalProblems = UserLocalProblems()
    var userLocalFile = URL.documentsURL.appendingPathComponent("UserLocalProblems.json")
    var userLocalStartIdx = 0
    var currentProblem: Problem = Problem()

    init() {
        knownProblems = loadKnownProblems(path: knownProblemsFile)
        userLocalStartIdx = knownProblems.count
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: userLocalFile.path) {
            FileManager.default.createFile(atPath: userLocalFile.path, contents: nil, attributes: nil)
        } else {
            ulp = loadUserLocalProblems(path: userLocalFile.path)
            knownProblems.append(contentsOf: ulp.userLocalProblems)
        }

    }

    func loadKnownProblems(path: String) -> [Problem] {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(KnownProblems.self, from: data)
            return jsonData.knownProblems
        } catch {
            print("error:\(error)")
            return []
        }
    }

    func loadUserLocalProblems(path: String) -> UserLocalProblems {
        do {
            let contents = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
            if (contents == "") {
                return UserLocalProblems()
            }
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(UserLocalProblems.self, from: data)
            return jsonData
        } catch {
            print("error:\(error)")
            return UserLocalProblems()
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

    func saveUserLocalProblems(path: URL, problems: UserLocalProblems) {
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(problems)
            try jsonData.write(to: path)
        }
        catch {
            print("error:\(error)")
        }
    }

    func stringifyCurrentProblem() -> String {
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(currentProblem)
            return String(data: jsonData, encoding: String.Encoding.utf8)!
        }
        catch {
            return "Failed to stringify current problem."
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

    func add(index: Int, hold: inout CAShapeLayer, type: HoldType, isSticky: Bool) {
        var currType = type
        if (isSticky) {
          currType = stickyToggle.value
        }
        switch currType {
        case HoldType.normal:
            currentProblem.normal.append(index)
        case HoldType.begin:
            currentProblem.begin.append(index)
        case HoldType.end:
            currentProblem.end.append(index)
        case HoldType.feetOnly:
            currentProblem.feetOnly.append(index)
        default:
            return
        }
        displayHold(type: currType, hold: &hold)
    }

    func getKnownProblemName() -> String {
        return knownProblems[knownProblemsIdx].name
    }

    func flushSaved(shapes: inout [CAShapeLayer]) {
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
    }

    // Should the original problem be removed?
    func prepareForEdit() {
        currentProblem.begin = knownProblems[knownProblemsIdx].begin
        currentProblem.end = knownProblems[knownProblemsIdx].end
        currentProblem.feetOnly = knownProblems[knownProblemsIdx].feetOnly
        currentProblem.normal = knownProblems[knownProblemsIdx].normal
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
        ulp.userLocalProblems.append(currentProblem)
        saveUserLocalProblems(path: userLocalFile, problems: ulp)
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
        if let idx = ulp.userLocalProblems.firstIndex(where: { $0 == currentProblem }) {
            ulp.userLocalProblems.remove(at: idx)
            saveUserLocalProblems(path: userLocalFile, problems: ulp)
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
