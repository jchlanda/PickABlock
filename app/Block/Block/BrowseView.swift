//
//  BrowseView.swift
//  Block
//
//  Created by Jakub on 11/03/2019.
//  Copyright © 2019 Jakub. All rights reserved.
//

import UIKit

extension UIButton
{
    func setUpLayer(button: UIButton?, displayName: String, x: Int, y: Int, width: Int, height: Int) {
        button!.setTitle(displayName, for: .normal)
        button!.setTitleColor(Defs.DarkRed, for: .normal)
        button!.layer.backgroundColor = Defs.White.withAlphaComponent(0.5).cgColor
        button!.layer.borderColor = Defs.DarkRed.cgColor
        button!.frame = CGRect(x: x, y: y, width:width, height:height)
        button!.layer.borderWidth = 1.0
        button!.layer.cornerRadius = 5.0
        button!.layer.shadowRadius =  3.0
        button!.layer.shadowColor =  Defs.White.cgColor
        button!.layer.shadowOpacity =  0.3
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
                backgroundColor = Defs.White
                titleLabel?.textColor = Defs.DarkRed
            }
            super.isHighlighted = newValue
        }
    }
}

class BrowseView: ImageScrollView {

    let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController

    lazy var mainSegment: UISegmentedControl = setUpSegmentedControl(elements: ["Edit", "Delete"], yOffset: 50)

    var nextButton = UIButton()
    var prevButton = UIButton()

    override func display(_ image: UIImage) {
        super.display(image)
        mainSegment.addTarget(self, action: #selector(BrowseView.mainSegmentedControlHandler(_:)), for: .valueChanged)
        superview?.addSubview(mainSegment)

        nextButton.setUpLayer(button: nextButton, displayName: "<", x: 0, y: Int(frame.maxY / 2 + 50), width: 35, height: 35)
        prevButton.setUpLayer(button: prevButton, displayName: ">", x: Int(frame.maxX - 35), y: Int(frame.maxY / 2 + 50), width: 35, height: 35)
        nextButton.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        prevButton.addTarget(self, action: #selector(prevButtonAction), for: .touchUpInside)

        superview?.addSubview(nextButton)
        superview?.addSubview(prevButton)
    }

    @objc func nextButtonAction(sender: UIButton!) {
        ImageScrollView.Problem.displayNextKnownProblem(shapes: &Shapes)
        setTitle()
    }

    @objc func prevButtonAction(sender: UIButton!) {
        ImageScrollView.Problem.displayPrevKnownProblem(shapes: &Shapes)
        setTitle()
    }

    func confirmDelete() {
        let canDelete = ImageScrollView.Problem.canDeleteProblem()
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alertController.view.tintColor = Defs.RedStroke
        
        if canDelete {
            alertController.title = "Are you sure you want to delete a problem?"
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (pAction) in
                ImageScrollView.Problem.deleteProblem()
                alertController.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(okAction)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (pAction) in
                alertController.dismiss(animated: true, completion: nil)
            }))
        } else {
            alertController.title = "The problem is in the default set and can not be removed."
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (pAction) in
                alertController.dismiss(animated: true, completion: nil)
            }))
        }
        
        // show alert controller
        let vc = findViewController()
        vc?.present(alertController, animated: true, completion: nil)
    }

    func setTitle() {
        navigationController!.viewControllers[1].navigationItem.title = ImageScrollView.Problem.getKnownProblemName()
    }

    //MARK: - Handle main segmented control, next and prev buttons.
    @objc func mainSegmentedControlHandler(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            var newViewControllers = navigationController!.viewControllers
            ImageScrollView.Problem.prepareForEdit()
            newViewControllers[1] = SetViewController()
            newViewControllers[1].view.backgroundColor = Defs.White
            newViewControllers[1].navigationItem.title = "Set"
            navigationController!.setViewControllers(newViewControllers, animated: true)
        case 1:
            confirmDelete()
        default:
            break
        }
    }
}
