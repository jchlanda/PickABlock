//
//  SetView.swift
//  Block
//
//  Created by Jakub on 11/03/2019.
//  Copyright © 2019 Jakub. All rights reserved.
//

import UIKit

class SetView: ImageScrollView {

    var longTouchPoint: CGPoint = CGPoint()
    
    var stickyToggle = false

    lazy var mainSegment: UISegmentedControl = setUpSegmentedControl(elements: ["Cancel", "Submit"], yOffset: 50)

    override func display(_ image: UIImage) {
        super.display(image)
        mainSegment.addTarget(self, action: #selector(SetView.mainSegmentedControlHandler(_:)), for: .valueChanged)
        superview?.addSubview(mainSegment)
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler))
        superview?.addGestureRecognizer(recognizer)

        // TODO: JKB: Here.
        ImageScrollView.Problem.flushSaved(shapes: &Shapes)
    }

    func createSwitch () -> UISwitch{
        let switchControl = UISwitch(frame:CGRect(x: 10, y: 20, width: 0, height: 0));
        switchControl.isOn = stickyToggle
        switchControl.setOn(stickyToggle, animated: false);
        switchControl.addTarget(self, action: #selector(self.switchValueDidChange), for: .valueChanged);
        return switchControl
    }
    
    @objc func switchValueDidChange(sender:UISwitch!){
        print("TODO: JKB: Finish Sticky.", sender as Any)
        print("sender.isOn:", sender.isOn)
        stickyToggle = sender.isOn
        ImageScrollView.Problem.changeSticky(isOn: sender.isOn)
    }
    
    // TODO: JKB: Should problem handle displayig shapes?
    func showSetSpecial(index: Int) {
        var shape = Shapes[index]
        let alertController = UIAlertController(title: "Set special:", message: "", preferredStyle: .alert)
        
        let customView = UIView()
        alertController.view.addSubview(customView)
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 45).isActive = true
        customView.rightAnchor.constraint(equalTo: alertController.view.rightAnchor, constant: -10).isActive = true
        customView.leftAnchor.constraint(equalTo: alertController.view.leftAnchor, constant: 10).isActive = true
        customView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        customView.frame = CGRect(x: 0 , y: 0, width: alertController.view.frame.width, height: alertController.view.frame.height * 0.7)
        let stickyLabel: UILabel = UILabel()
        stickyLabel.text = "Sticky"
        stickyLabel.frame = CGRect(x: 80, y: 25, width: 80, height: 20)
        stickyLabel.textAlignment = NSTextAlignment.center
        stickyLabel.textColor = Defs.RedStroke
        customView.addSubview(stickyLabel)
        customView.addSubview(createSwitch())

        alertController.view.translatesAutoresizingMaskIntoConstraints = false
        alertController.view.heightAnchor.constraint(equalToConstant: 325).isActive = true
        alertController.view.tintColor = Defs.RedStroke
        
        let begin = UIAlertAction(title: "Begin", style: UIAlertAction.Style.default) {
            UIAlertAction in
            ImageScrollView.Problem.add(index: index, hold: &shape, type: BlockProblem.HoldType.begin)
        }
        let end = UIAlertAction(title: "End", style: UIAlertAction.Style.default) {
            UIAlertAction in
            ImageScrollView.Problem.add(index: index, hold: &shape, type: BlockProblem.HoldType.end)
        }
        let feet = UIAlertAction(title: "Feet only", style: UIAlertAction.Style.default) {
            UIAlertAction in
            ImageScrollView.Problem.add(index: index, hold: &shape, type: BlockProblem.HoldType.feetOnly)
        }
        let normal = UIAlertAction(title: "Normal", style: UIAlertAction.Style.default) {
            UIAlertAction in
            ImageScrollView.Problem.add(index: index, hold: &shape, type: BlockProblem.HoldType.normal)
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

    //MARK: - Handle Tap and Zoom.
    @objc func longPressHandler(sender: UILongPressGestureRecognizer) {
        if (sender.state != UIGestureRecognizer.State.began) {
            return
        }
        for i in 0..<Shapes.count {
            if Shapes[i].path!.contains(longTouchPoint) {
                ImageScrollView.Problem.remove(index: i, hold: &Shapes[i])
                showSetSpecial(index: i)
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let point = touch!.location(in: self.zoomView)
        longTouchPoint = point
        for i in 0..<Shapes.count {
            var sh = Shapes[i]
            if sh.path!.contains(point) {
                if (sh.opacity == 0) {
                    ImageScrollView.Problem.add(index: i, hold: &sh, type: BlockProblem.HoldType.normal)
                } else {
                    ImageScrollView.Problem.remove(index: i, hold: &sh)
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
            ImageScrollView.Problem.serialize(shapes: &self.Shapes, name: problemName)
            alertController.dismiss(animated: true, completion: nil)
        })
        okAction.isEnabled = false
        alertController.addAction(okAction)
        // show alert controller
        let vc = findViewController()
        vc?.present(alertController, animated: true, completion: nil)
    }

    //MARK: - Handle main segmented control.
    @objc func mainSegmentedControlHandler(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            ImageScrollView.Problem.clean(shapes: &Shapes)
            break
        case 1:
            showSubmit()
            break
        default:
            break
        }
    }
}
