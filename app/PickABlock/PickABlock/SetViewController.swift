//
//  SetViewController.swift
//  Block
//
//  Created by Jakub on 11/03/2019.
//  Copyright © 2019 Jakub. All rights reserved.
//

import UIKit

class SetViewController: ViewController {
  
  override func viewDidLoad() {
    self.imageScrollView = SetView(frame: self.view.bounds)
    self.image = UIImage(named: "AlienBlockAR2")!
    
    super.viewDidLoad()
  }

  func setEditState(knownProblemsIdx: Int) {
    self.imageScrollView.setEditState(knownProblemsIdx: knownProblemsIdx)
  }
}

