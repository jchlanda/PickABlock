//
//  ViewController.swift
//  BlockSet
//
//  Created by Jakub on 11/03/2019.
//  Copyright © 2019 Jakub. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var imageScrollView: ImageScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1. Initialize imageScrollView and adding it to viewControllers view
        self.imageScrollView = ImageScrollView(frame: self.view.bounds)
        self.view.addSubview(self.imageScrollView)
        self.layoutImageScrollView()
        
        //2. Making an image from our photo path
        // let imagePath = Bundle.main.path(forResource: "AlienBlockAR2", ofType: "jpeg")!
        // let image = UIImage(contentsOfFile: imagePath)!
        let image = UIImage(named: "AlienBlockAR2")!
        
        //3. Ask imageScrollView to show image
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

