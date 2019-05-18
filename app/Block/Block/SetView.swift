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
  
  var overlayMode = false
  var overlayPath = UIBezierPath()
  var overlayPaths: [ColoredOverlayPath] = []
  
  lazy var mainSegment: UISegmentedControl = Defs.setUpSegmentedControl(frame: self.frame, elements: ["Cancel", "Submit"], yOffset: yOffset)
  lazy var colorSegment: UISegmentedControl = Defs.setUpSegmentedControl(frame: self.frame, elements: [""], yOffset: yOffset + 50)
  
  var slider = UISlider()
  
  enum undoRedoState {
    case normal
    case undo
  }
  var redoButton = UIButton()
  var undoButton = UIButton()
  var undoStack: [ColoredOverlayPath] = []
  var undoRedo: undoRedoState = undoRedoState.normal
  
  override func display(_ image: UIImage) {
    super.display(image)
    mainSegment.addTarget(self, action: #selector(SetView.mainSegmentedControlHandler(_:)), for: .valueChanged)
    superview?.addSubview(mainSegment)
    superview?.addSubview(colorSegment)
    slider = setUpSlider()
    superview?.addSubview(slider)
    
    let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler))
    superview?.addGestureRecognizer(recognizer)
    
    redoButton.setUpLayer(button: redoButton, displayName: ">", x: Int(frame.maxX - 10 - 35), y: Int(frame.maxY - yOffset - 50), width: 35, height: 40)
    redoButton.layer.cornerRadius = 15.0
    redoButton.layer.borderWidth = 1.0
    redoButton.layer.masksToBounds = true
    undoButton.setUpLayer(button: undoButton, displayName: "<", x: Int(frame.minX + 10), y: Int(frame.maxY - yOffset - 50), width: 35, height: 40)
    undoButton.layer.cornerRadius = 15.0
    undoButton.layer.borderWidth = 1.0
    undoButton.layer.masksToBounds = true
    redoButton.addTarget(self, action: #selector(redoButtonAction), for: .touchUpInside)
    undoButton.addTarget(self, action: #selector(undoButtonAction), for: .touchUpInside)
    superview?.addSubview(redoButton)
    superview?.addSubview(undoButton)
    setColorPickerVisibility(isHidden: true)
  }

  @objc func redoButtonAction(sender: UIButton!) {
    if (undoStack.count == 0) {
      return
    }
    let redone = undoStack.popLast()
    let strokeColorAlpha1 = UIColor(cgColor: redone!.overlayShapePath.strokeColor!).withAlphaComponent(1)
    redone!.overlayShapePath.strokeColor = strokeColorAlpha1.cgColor
    overlayPaths.append(redone!)
  }
  
  @objc func undoButtonAction(sender: UIButton!) {
    if (undoRedo == undoRedoState.normal) {
      undoStack.removeAll()
      undoRedo = undoRedoState.undo
    }
    if (overlayPaths.count == 0) {
      return
    }
    let undone = overlayPaths.popLast()
    let strokeColorAlpha0 = UIColor(cgColor: undone!.overlayShapePath.strokeColor!).withAlphaComponent(0)
    undone!.overlayShapePath.strokeColor = strokeColorAlpha0.cgColor
    undoStack.append(undone!)
  }
  
  func cleanOverlays() {
    for u in undoStack {
      let strokeColorAlpha0 = UIColor(cgColor: u.overlayShapePath.strokeColor!).withAlphaComponent(0)
      u.overlayShapePath.strokeColor = strokeColorAlpha0.cgColor
    }
    for o in overlayPaths {
      let strokeColorAlpha0 = UIColor(cgColor: o.overlayShapePath.strokeColor!).withAlphaComponent(0)
      o.overlayShapePath.strokeColor = strokeColorAlpha0.cgColor
    }
    undoStack.removeAll()
    overlayPaths.removeAll()
  }
  
  func setUpSlider() -> UISlider {
    let slider = UISlider()
    slider.frame = CGRect(x: frame.minX + 10 + 35, y: frame.maxY - yOffset - 50,
                          width: frame.maxX - 2 * 10 - 2 * 35, height: 40)
    
    slider.minimumTrackTintColor = Defs.White.withAlphaComponent(0)
    slider.maximumTrackTintColor = Defs.White.withAlphaComponent(0)
    slider.maximumValue = 13
    slider.minimumValue = 0
    slider.setValue(6.5, animated: false)
    slider.thumbTintColor = Defs.uiColorFromHex(rgbValue: Defs.colorArray[Int(slider.value)])
    
    slider.addTarget(self,action: #selector(self.sliderChanged),  for: .valueChanged)
    
    return slider
  }
  
  @objc func sliderChanged(sender: AnyObject) {
    slider.thumbTintColor = Defs.uiColorFromHex(rgbValue: Defs.colorArray[Int(slider.value)])
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
        self.getBlockProblemManager().setSticky(type: HoldType.begin)
        self.stickyChanged = false
      }
      self.getBlockProblemManager().add(index: index, hold: &shape, type: HoldType.begin, isSticky: self.stickyToggle)
    }
    let end = UIAlertAction(title: "End", style: UIAlertAction.Style.default) {
      UIAlertAction in
      if (self.stickyChanged) {
        self.getBlockProblemManager().setSticky(type: HoldType.end)
        self.stickyChanged = false
      }
      self.getBlockProblemManager().add(index: index, hold: &shape, type: HoldType.end, isSticky: self.stickyToggle)
    }
    let feet = UIAlertAction(title: "Feet only", style: UIAlertAction.Style.default) {
      UIAlertAction in
      if (self.stickyChanged) {
        self.getBlockProblemManager().setSticky(type: HoldType.feetOnly)
        self.stickyChanged = false
      }
      self.getBlockProblemManager().add(index: index, hold: &shape, type: HoldType.feetOnly, isSticky: self.stickyToggle)
    }
    let normal = UIAlertAction(title: "Normal", style: UIAlertAction.Style.default) {
      UIAlertAction in
      if (self.stickyChanged) {
        self.getBlockProblemManager().setSticky(type: HoldType.normal)
        self.stickyChanged = false
      }
      self.getBlockProblemManager().add(index: index, hold: &shape, type: HoldType.normal, isSticky: self.stickyToggle)
    }
    let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
      UIAlertAction in
    }
    alertController.addAction(begin)
    alertController.addAction(end)
    alertController.addAction(feet)
    alertController.addAction(normal)
    alertController.addAction(cancel)
    
    let vc = findViewController()
    vc?.present(alertController, animated: true, completion: nil)
  }
  
  @objc func longPressHandler(sender: UILongPressGestureRecognizer) {
    if (sender.state != UIGestureRecognizer.State.began) {
      return
    }
    for i in 0..<Shapes.count {
      if Shapes[i].path!.contains(longTouchPoint) {
        generator.impactOccurred()
        getBlockProblemManager().remove(index: i, hold: &Shapes[i])
        showSetSpecial(index: i)
        return
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
          getBlockProblemManager().add(index: i, hold: &sh, type: HoldType.normal, isSticky: stickyToggle)
        } else {
          getBlockProblemManager().remove(index: i, hold: &sh)
        }
      }
    }
    if (overlayMode) {
      overlayPath.removeAllPoints()
      overlayPath.move(to: point)
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if (overlayMode) {
      let touch = touches.first
      let point = touch!.location(in: self.zoomView)
      overlayPath.addLine(to: point)
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if (overlayMode) {
      undoRedo = undoRedoState.normal
      let touch = touches.first
      let point = touch!.location(in: self.zoomView)
      overlayPath.addLine(to: point)
      
      var simplifiedOverlayPath = overlayPath.cgPath.ramerDouglasPeuckerPoints
      if (simplifiedOverlayPath.count < 2) {
        return
      }
      let Shape = CAShapeLayer()
      self.zoomView.layer.addSublayer(Shape)
      Shape.opacity = 0.5
      Shape.lineWidth = 4
      Shape.lineJoin = CAShapeLayerLineJoin.miter
      Shape.strokeColor = Defs.uiColorFromHex(rgbValue: Defs.colorArray[Int(slider.value)]).cgColor
      Shape.fillColor = Defs.NoFill.cgColor
      let overlayPath: UIBezierPath = UIBezierPath()
      overlayPath.move(to: simplifiedOverlayPath[0])
      for so in simplifiedOverlayPath {
        overlayPath.addLine(to: so)
      }
      Shape.path = overlayPath.cgPath
      overlayPaths.append(ColoredOverlayPath(index: Int(slider.value), shapePath: Shape))
    }
  }
  
  @objc func alertTextFieldDidChange(field: UITextField){
    let vc = findViewController()
    let alertController:UIAlertController = vc?.presentedViewController as! UIAlertController;
    let textField: UITextField  = alertController.textFields![0];
    let addAction: UIAlertAction = alertController.actions[1];
    addAction.isEnabled = (textField.text?.count)! >= 1;
  }
  
  func setColorPickerVisibility(isHidden: Bool) {
    self.colorSegment.isHidden = isHidden
    self.slider.isHidden = isHidden
    self.redoButton.isHidden = isHidden
    self.undoButton.isHidden = isHidden
  }
  
  func showAddOverlay() {
    let alertController = UIAlertController(title: "Add overlay?", message: "", preferredStyle: .alert)
    alertController.view.tintColor = Defs.RedStroke
    
    alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (pAction) in
      alertController.dismiss(animated: true, completion: nil)
      self.showSubmit()
      self.overlayMode = false
      self.setColorPickerVisibility(isHidden: true)
    }))
    alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (pAction) in
      alertController.dismiss(animated: true, completion: nil)
      self.overlayMode = true
      self.setColorPickerVisibility(isHidden: false)
    }))
    // show alert controller
    let vc = findViewController()
    vc?.present(alertController, animated: true, completion: nil)
    
  }
  
  func showSubmit() {
    overlayMode = false
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
      self.setColorPickerVisibility(isHidden: true)
      alertController.dismiss(animated: true, completion: nil)
    }))
    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (pAction) in
      self.setColorPickerVisibility(isHidden: true)
      let problemName = textField?.text ?? ""
      self.getBlockProblemManager().serialize(name: problemName, overlays: self.overlayPaths)
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
    case 0: // Cancel
      getBlockProblemManager().clean(oldIdx: getBlockProblemManager().getKnownProblemIdx(), shapes: &Shapes)
      setColorPickerVisibility(isHidden: true)
      cleanOverlays()
      overlayMode = false
      break
    case 1: // Submit
      if (!overlayMode) {
        showAddOverlay()
      } else {
        showSubmit()
      }
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
