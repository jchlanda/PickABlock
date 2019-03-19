//
//  ViewController.swift
//  Block
//
//  Created by Jakub on 18/03/2019.
//  Copyright © 2019 Jakub. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var imageScrollView: ImageScrollView!
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.imageScrollView)
        self.layoutImageScrollView()
        
        self.imageScrollView.display(image)
    }
    
    func layoutImageScrollView() {
        self.imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let top = NSLayoutConstraint(item: self.imageScrollView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0)
        let left = NSLayoutConstraint(item: self.imageScrollView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0)
        
        let bottom = NSLayoutConstraint(item: self.imageScrollView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let right = NSLayoutConstraint(item: self.imageScrollView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0)
        
        self.view.addConstraints([top, left, bottom, right])
    }
}

