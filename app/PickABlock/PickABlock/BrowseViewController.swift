//
//  BrowseViewController.swift
//  Block
//
//  Created by Jakub on 18/03/2019.
//  Copyright © 2019 Jakub. All rights reserved.
//

import UIKit

class BrowseViewController: ViewController {

  override func viewDidLoad() {
    self.imageScrollView = BrowseView(frame: self.view.bounds)
    self.image = UIImage(named: "AlienBlockAR2")!

    super.viewDidLoad()
  }
}
