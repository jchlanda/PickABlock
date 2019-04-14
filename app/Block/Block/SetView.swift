//
//  SetView.swift
//  Block
//
//  Created by Jakub on 11/03/2019.
//  Copyright © 2019 Jakub. All rights reserved.
//

import UIKit

class SetView: ImageScrollView {

    let generator = UIImpactFeedbackGenerator(style: .light)
    var longTouchPoint: CGPoint = CGPoint()
    
    var stickyToggle = false
    var stickyChanged = false

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
        stickyChanged = sender.isOn
        stickyToggle = sender.isOn
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
        stickyLabel.font = UIFont.boldSystemFont(ofSize: stickyLabel.font.pointSize)
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
            if (self.stickyChanged) {
                ImageScrollView.Problem.setSticky(type: HoldType.begin)
                self.stickyChanged = false
            }
            ImageScrollView.Problem.add(index: index, hold: &shape, type: HoldType.begin, isSticky: self.stickyToggle)
        }
        let end = UIAlertAction(title: "End", style: UIAlertAction.Style.default) {
            UIAlertAction in
            if (self.stickyChanged) {
                ImageScrollView.Problem.setSticky(type: HoldType.end)
                self.stickyChanged = false
            }
            ImageScrollView.Problem.add(index: index, hold: &shape, type: HoldType.end, isSticky: self.stickyToggle)
        }
        let feet = UIAlertAction(title: "Feet only", style: UIAlertAction.Style.default) {
            UIAlertAction in
            if (self.stickyChanged) {
                ImageScrollView.Problem.setSticky(type: HoldType.feetOnly)
                self.stickyChanged = false
            }
            ImageScrollView.Problem.add(index: index, hold: &shape, type: HoldType.feetOnly, isSticky: self.stickyToggle)
        }
        let normal = UIAlertAction(title: "Normal", style: UIAlertAction.Style.default) {
            UIAlertAction in
            if (self.stickyChanged) {
                ImageScrollView.Problem.setSticky(type: HoldType.normal)
                self.stickyChanged = false
            }
            ImageScrollView.Problem.add(index: index, hold: &shape, type: HoldType.normal, isSticky: self.stickyToggle)
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
                generator.impactOccurred()
                if (sh.opacity == 0) {
                    ImageScrollView.Problem.add(index: i, hold: &sh, type: HoldType.normal, isSticky: stickyToggle)
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

extension CGPath {
    var points: [CGPoint] {
        var arrPoints: [CGPoint] = []
        ///< applyWithBlock lets us examine each element of the CGPath, and decide what to do
        self.applyWithBlock { element in
            switch element.pointee.type
            {
            case .moveToPoint, .addLineToPoint:
                arrPoints.append(element.pointee.points.pointee)
            case .addQuadCurveToPoint:
                arrPoints.append(element.pointee.points.pointee)
                arrPoints.append(element.pointee.points.advanced(by: 1).pointee)
            case .addCurveToPoint:
                arrPoints.append(element.pointee.points.pointee)
                arrPoints.append(element.pointee.points.advanced(by: 1).pointee)
                arrPoints.append(element.pointee.points.advanced(by: 2).pointee)
            default:
                break
            }
        }
        return arrPoints
    }

    var ramerDouglasPeuckerPoints: [CGPoint] {
        let inPoints = self.points
        var outPoints: [CGPoint] = []
        ramerDouglasPeucker(path: inPoints, startIdx: 0, endIdx: (inPoints.count - 1), epsilon: 0.05, simplified: &outPoints)
        return outPoints
    }

    func perpendicularDistance(point: CGPoint, a: CGFloat, c: CGFloat) -> CGFloat {
        // d = (|a*x0 + b*y0 + c|)/(sqrt(a^2 + b^2))
        let b: CGFloat = 1.0
        let dividend = abs(a * point.x + b * point.y + c)
        let divisor = sqrt(a * a + c * c)
        let d = dividend/divisor

        return d
    }

    func ramerDouglasPeucker(path: [CGPoint], startIdx: Int, endIdx: Int, epsilon: CGFloat, simplified: inout [CGPoint]) {
        if (endIdx - startIdx < 1) {
            return
        }
        let m = (path[startIdx].y - path[endIdx].y)/(path[startIdx].x - path[endIdx].x) * (-1.0)
        let b = (m * path[startIdx].x + path[startIdx].y) * (-1.0)
        var dmax: CGFloat = 0.0
        var dmaxIdx = 0
        var d: CGFloat = 0.0
        for i in (startIdx + 1)..<endIdx {
            d = perpendicularDistance(point: path[i], a: m, c: b)
            if (d > dmax) {
                dmaxIdx = i
                dmax = d
            }
        }
        if (dmax > epsilon) {
            var bottomAcc: [CGPoint] = []
            ramerDouglasPeucker(path: path, startIdx: startIdx, endIdx: dmaxIdx - 1, epsilon: epsilon, simplified: &bottomAcc)
            var topAcc: [CGPoint] = []
            ramerDouglasPeucker(path: path, startIdx: dmaxIdx, endIdx: endIdx,  epsilon: epsilon, simplified: &topAcc)
            simplified.removeAll()
            simplified.append(contentsOf: bottomAcc)
            simplified.append(contentsOf: topAcc)
            if (simplified.count < 2) {
                return
            }
        } else {
            simplified.removeAll()
            simplified.append(path[startIdx])
            simplified.append(path[endIdx])
        }
        return
    }
}
