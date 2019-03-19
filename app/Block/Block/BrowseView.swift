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

    var MaxPossibleForceShape = 0

    lazy var mainSegment: UISegmentedControl = setUpSegmentedControl(elements: ["Edit", "Delete"], yOffset: 60)

    var nextButton = UIButton()
    var prevButton = UIButton()
    
    override func display(_ image: UIImage) {
        super.display(image)
        mainSegment.addTarget(self, action: #selector(BrowseView.mainSegmentedControlHandler(_:)), for: .valueChanged)
        superview?.addSubview(mainSegment)
        
        nextButton.setUpLayer(button: nextButton, displayName: "<", x: 0, y: Int(frame.maxY / 2 + 50), width: 35, height: 35)
        prevButton.setUpLayer(button: prevButton, displayName: ">", x: Int(frame.maxX - 35), y: Int(frame.maxY / 2 + 50), width: 35, height: 35)
//        nextButton.addTarget(self, action: #selector(BrowseView.nextPrevControlHandler(_:)), for: .valueChanged)
//        prevButton.addTarget(self, action: #selector(BrowseView.nextPrevControlHandler(_:)), for: .valueChanged)
//
        nextButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        prevButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        superview?.addSubview(nextButton)
        superview?.addSubview(prevButton)
    }
    
    @objc func buttonAction(sender: UIButton!) {
        print("Button Clicked")
    }
//@objc func woof(){
//    let vc = findViewController()
//    let alertController:UIAlertController = vc?.presentedViewController as! UIAlertController;
//    let vc = findViewController()
//    vc?.present(alertController, animated: true, completion: nil)
//}

    //MARK: - Handle Tap and Zoom.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let point = touch!.location(in: self.zoomView)
        for (i, sh) in Shapes.enumerated() {
            if sh.path!.contains(point) {
                if touch!.force == touch?.maximumPossibleForce {
                    self.MaxPossibleForceShape = i
                    showSetSpecial()
                    sh.opacity = 0.5
                    Problem.add(hold: i)
                } else {
                    if (sh.opacity == 0) {
                        Problem.add(hold: i)
                        sh.opacity = 0.5
                    } else {
                        Problem.remove(hold: i)
                        sh.opacity = 0
                    }
                }
            }
        }
    }

    // MARK: - Show submit alert and text field observer.
    @objc func alertTextFieldDidChange(field: UITextField){
        let vc = findViewController()
        let alertController:UIAlertController = vc?.presentedViewController as! UIAlertController;
        let textField :UITextField  = alertController.textFields![0];
        let addAction: UIAlertAction = alertController.actions[1];
        addAction.isEnabled = (textField.text?.count)! >= 5;

    }

    func showSubmit() {
        var textField: UITextField?
        // create alertController
        let alertController = UIAlertController(title: "Submit a problem", message: "", preferredStyle: .alert)
        alertController.view.tintColor = Defs.RedStroke

        alertController.addTextField { (pTextField) in
            pTextField.placeholder = "name or descriptioin"
            pTextField.clearButtonMode = .whileEditing
            pTextField.borderStyle = .none
            pTextField.addTarget(self, action: #selector(self.alertTextFieldDidChange(field:)), for: UIControl.Event.editingChanged)
            textField = pTextField
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (pAction) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (pAction) in
            let problemName = textField?.text ?? ""
            self.Problem.serialize(shapes: &self.Shapes, name: problemName)
            alertController.dismiss(animated: true, completion: nil)
        })
        okAction.isEnabled = false
        alertController.addAction(okAction)
        // show alert controller
        let vc = findViewController()
        vc?.present(alertController, animated: true, completion: nil)
    }

    func showSetSpecial() {
        let Shape = Shapes[MaxPossibleForceShape]
        let alertController = UIAlertController(title: "Set special:", message: "", preferredStyle: .alert)
        alertController.view.tintColor = Defs.RedStroke

        let begin = UIAlertAction(title: "Begin", style: UIAlertAction.Style.default) {
            UIAlertAction in
            Shape.strokeColor = Defs.GreenStroke.cgColor
            Shape.fillColor = Defs.GreenFill.cgColor
        }
        let end = UIAlertAction(title: "End", style: UIAlertAction.Style.default) {
            UIAlertAction in
            Shape.strokeColor = Defs.BlueStroke.cgColor
            Shape.fillColor = Defs.BlueFill.cgColor
        }
        let feet = UIAlertAction(title: "Feet only", style: UIAlertAction.Style.default) {
            UIAlertAction in
            Shape.strokeColor = Defs.YellowStroke.cgColor
            Shape.fillColor = Defs.YellowFill.cgColor
        }
        let normal = UIAlertAction(title: "Normal", style: UIAlertAction.Style.default) {
            UIAlertAction in
            Shape.strokeColor = Defs.RedStroke.cgColor
            Shape.fillColor = Defs.RedFill.cgColor
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
        }
        // Add the actions
        alertController.addAction(begin)
        alertController.addAction(end)
        alertController.addAction(feet)
        alertController.addAction(normal)
        alertController.addAction(cancel)

        let vc = findViewController()
        vc?.present(alertController, animated: true, completion: nil)
    }

    //MARK: - Handle main segmented control, next and prev buttons.
    @objc func mainSegmentedControlHandler(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            Problem.clean(shapes: &Shapes)
            break
        case 1:
            showSubmit()
            break
        default:
            break
        }
    }
}
