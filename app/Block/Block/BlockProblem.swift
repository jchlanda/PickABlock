//
//  BlockProblem.swift
//  Block
//
//  Created by Jakub on 12/03/2019.
//  Copyright © 2019 Jakub. All rights reserved.
//

import Foundation
import UIKit

struct KnownProblems : Decodable {
    var knownProblems: [Problem]
}

struct Problem : Decodable {
    var name: String
    var begin: [Int]
    var end: [Int]
    var feetOnly: [Int]
    var normal: [Int]
}

// TODO: JKB: BlockProblem should hold the shapes. Pass it to view controller onlly to be added to the layer, at the time of initialization.
// TODO: it should have an init function that would call loadJSON
class BlockProblem {
    enum HoldType {
        case begin
        case end
        case feetOnly
        case normal
        case none
    }
    var knownProblems: [Problem]
    var knownProblemsIdx: Int
    var name: String
    var begin: [Int]
    var end: [Int]
    var feetOnly: [Int]
    var normal: [Int]
    
    init() {
        knownProblems = []
        knownProblemsIdx = 0
        name = ""
        begin = []
        end = []
        feetOnly = []
        normal = []
        
        loadJSON()
    }
    
    func loadJSON() {
        if let path :String = Bundle.main.path(forResource: "KnownProblems", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(KnownProblems.self, from: data)
                knownProblems = jsonData.knownProblems
            } catch {
                print("error:\(error)")
            }
        }
    }

    func displayNextKnownProblem(shapes: inout [CAShapeLayer]) {
        if (knownProblemsIdx == knownProblems.count - 1) {
            knownProblemsIdx = 0
        } else {
            knownProblemsIdx += 1
        }
        displayKnownProblem(problemIdx: knownProblemsIdx, shapes: &shapes)
    }

    func displayPrevKtnownProblem(shapes: inout [CAShapeLayer]) {
        if (knownProblemsIdx == 0) {
            knownProblemsIdx = knownProblems.count - 1
        } else {
            knownProblemsIdx -= 1
        }
        displayKnownProblem(problemIdx: knownProblemsIdx, shapes: &shapes)
    }

    func displayKnownProblem(problemIdx: Int, shapes: inout [CAShapeLayer]) {
        clean(shapes: &shapes)
        let problem = knownProblems[problemIdx]
        for b in problem.begin {
            displayHold(type: HoldType.begin, hold: &shapes[b])
            begin.append(b)
        }
        for e in problem.end {
            displayHold(type: HoldType.end, hold: &shapes[e])
            end.append(e)
        }
        for f in problem.feetOnly {
            displayHold(type: HoldType.feetOnly, hold: &shapes[f])
            feetOnly.append(f)
        }
        for n in problem.normal {
            displayHold(type: HoldType.normal, hold: &shapes[n])
            normal.append(n)
        }
    }

    func displayHold(type: HoldType, hold: inout CAShapeLayer) {
        hold.opacity = 0.5
        switch type {
        case HoldType.begin:
            hold.strokeColor = Defs.GreenStroke.cgColor
            hold.fillColor = Defs.GreenFill.cgColor
        case HoldType.end:
            hold.strokeColor = Defs.BlueStroke.cgColor
            hold.fillColor = Defs.BlueFill.cgColor
        case HoldType.feetOnly:
            hold.strokeColor = Defs.YellowStroke.cgColor
            hold.fillColor = Defs.YellowFill.cgColor
        case HoldType.normal:
            hold.strokeColor = Defs.RedStroke.cgColor
            hold.fillColor = Defs.RedFill.cgColor
        default:
            hold.strokeColor = Defs.RedStroke.cgColor
            hold.fillColor = Defs.RedFill.cgColor
            hold.opacity = 0
        }
    }
    
    func remove(index: Int, hold: inout CAShapeLayer) {
        hold.strokeColor = Defs.RedStroke.cgColor
        hold.fillColor = Defs.RedFill.cgColor
        hold.opacity = 0
        if let i = normal.index(of: index) {
            normal.remove(at: i)
            return
        }
        if let i = begin.index(of: index) {
            begin.remove(at: i)
            return
        }
        if let i = end.index(of: index) {
            end.remove(at: i)
            return
        }
        if let i = feetOnly.index(of: index) {
            feetOnly.remove(at: i)
            return
        }
    }
    
    func add(index: Int, hold: inout CAShapeLayer, type: HoldType) {
        switch type {
        case HoldType.normal:
            normal.append(index)
        case HoldType.begin:
            begin.append(index)
        case HoldType.end:
            end.append(index)
        case HoldType.feetOnly:
            feetOnly.append(index)
        default:
            return
        }
        displayHold(type: type, hold: &hold)
    }
    
    func setName(name: String) {
        self.name = name
    }
    
    func serialize(shapes: inout [CAShapeLayer], name: String) {
        print("Submit:")
        print("begin:")
        for (i, hold) in begin.enumerated() {
            let Shape = shapes[hold]
            print("i: ", i, " -> hold: ", hold)
            print (Shape)
        }
        print("end:")
        for (i, hold) in end.enumerated() {
            let Shape = shapes[hold]
            print("i: ", i, " -> hold: ", hold)
            print (Shape)
        }
        print("feetOnly:")
        for (i, hold) in feetOnly.enumerated() {
            let Shape = shapes[hold]
            print("i: ", i, " -> hold: ", hold)
            print (Shape)
        }
        print("normal:")
        for (i, hold) in normal.enumerated() {
            let Shape = shapes[hold]
            print("i: ", i, " -> hold: ", hold)
            print (Shape)
        }
    }
    
    func clean(shapes: inout [CAShapeLayer]) {
        for b in begin {
            shapes[b].opacity = 0
            shapes[b].strokeColor = Defs.RedStroke.cgColor
            shapes[b].fillColor = Defs.RedFill.cgColor
        }
        begin.removeAll()
        for e in end {
            shapes[e].opacity = 0
            shapes[e].strokeColor = Defs.RedStroke.cgColor
            shapes[e].fillColor = Defs.RedFill.cgColor
        }
        end.removeAll()
        for n in normal {
            shapes[n].opacity = 0
            shapes[n].strokeColor = Defs.RedStroke.cgColor
            shapes[n].fillColor = Defs.RedFill.cgColor
        }
        normal.removeAll()
        for f in feetOnly {
            shapes[f].opacity = 0
            shapes[f].strokeColor = Defs.RedStroke.cgColor
            shapes[f].fillColor = Defs.RedFill.cgColor
        }
        feetOnly.removeAll()
    }

    func deleteProblem() {
        print("BlockProblem -> deleteProblem")
    }
}
