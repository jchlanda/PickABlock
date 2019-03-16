//
//  BlockProblem.swift
//  BlockSet
//
//  Created by Jakub on 12/03/2019.
//  Copyright © 2019 Jakub. All rights reserved.
//

import Foundation
import UIKit

class BlockProblem {
    var Holds: [Int] = []

    func remove(hold: Int) {
        if let i = Holds.index(of: hold) {
            Holds.remove(at: i)
        }
    }

    func add(hold: Int) {
       Holds.append(hold)
    }

    func serialize(shapes: UnsafeMutablePointer<CAShapeLayer>, name: String) {
        if (Holds.isEmpty) {
            return
        }
        for (i, hold) in Holds.enumerated() {
            let Shape = shapes[hold]
            print("i: ", i, " -> hold: ", hold)
            print (Shape)
        }

        print("Submit Success")
    }

    func clean(shapes: UnsafeMutablePointer<CAShapeLayer>) {
        for hold in Holds {
            shapes[hold].opacity = 0
            shapes[hold].strokeColor = Defs.RedStroke.cgColor
            shapes[hold].fillColor = Defs.RedFill.cgColor
        }
        Holds.removeAll()
    }
}
