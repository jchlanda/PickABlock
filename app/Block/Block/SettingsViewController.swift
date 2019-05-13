//
//  SettingsViewController.swift
//  Block
//
//  Created by Jakub on 18/03/2019.
//  Copyright © 2019 Jakub. All rights reserved.
//

import UIKit

class SettingsViewController: ViewController {
  let labelOne: UILabel = {
    let label = UILabel()
    label.text = "Scroll Top"
    label.backgroundColor = .red
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  let labelTwo: UILabel = {
    let label = UILabel()
    label.text = "Scroll Bottom"
    label.backgroundColor = .green
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  let scrollView: UIScrollView = {
    let v = UIScrollView()
    v.translatesAutoresizingMaskIntoConstraints = false
    return v
  }()
  
  func getTextField(frame: CGRect, placecholder: String) -> UITextField {
    let tf = UITextField(frame: frame)
    tf.placeholder = placecholder
    //tf.font = UIFont.systemFont(ofSize: 15)
    //tf.borderStyle = UITextField.BorderStyle.roundedRect
    tf.layer.borderColor = Defs.DarkRed.cgColor
    tf.layer.cornerRadius = 15.0
    tf.layer.borderWidth = 1.0
    tf.tintColor = Defs.DarkRed
    tf.keyboardType = UIKeyboardType.default
    tf.returnKeyType = UIReturnKeyType.done
    tf.clearButtonMode = UITextField.ViewMode.whileEditing
    tf.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
    tf.leftView = paddingView
    tf.leftViewMode = UITextField.ViewMode.always
    
    return tf
  }
  
  lazy var mainSegment: UISegmentedControl = Defs.setUpSegmentedControl(frame: self.view.bounds.integral, elements: ["Cancel", "Submit"], yOffset: 120)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // add the scroll view to self.view
    self.view.addSubview(scrollView)
    
    // getBlockProblem().setSticky(type: HoldType.begin)
    
    // constrain the scroll view to 8-pts on each side
    scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
    scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
    scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
    scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    
    // add labelOne to the scroll view
    scrollView.addSubview(labelOne)
    
    // constrain labelOne to left & top with 16-pts padding
    // this also defines the left & top of the scroll content
    labelOne.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.0).isActive = true
    labelOne.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16.0).isActive = true
    
    // add labelTwo to the scroll view
    scrollView.addSubview(labelTwo)
    
    // constrain labelTwo at 400-pts from the left
    labelTwo.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 200).isActive = true
    
    // constrain labelTwo at 1000-pts from the top
    labelTwo.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 500).isActive = true
    
    // constrain labelTwo to right & bottom with 16-pts padding
//    labelTwo.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -16.0).isActive = true
//    labelTwo.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16.0).isActive = true
    
    
    let userLocalProblemsTextField = getTextField(frame: CGRect(x: 20, y: 100, width: 300, height: 40), placecholder: "User Local Problems")
    if (BPM.hasUserLocalProblems()) {
      userLocalProblemsTextField.text = BPM.stringifyProblems(startIdx: BPM.getUserLocalStartIdx(), endIdx: BPM.getNumKnownProblems() - 1)
    }
    scrollView.addSubview(userLocalProblemsTextField)

    let buildInProblems = getTextField(frame: CGRect(x: 20, y: 200, width: 300, height: 40), placecholder: "Build In Problems")
    buildInProblems.text = BPM.stringifyProblems(startIdx: 0, endIdx: BPM.getUserLocalStartIdx() - 1)
    scrollView.addSubview(buildInProblems)
    
    let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.shareButtonPressed))
    let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
    navigationController!.viewControllers[1].navigationItem.rightBarButtonItem = shareButton
    
    mainSegment.addTarget(self, action: #selector(SettingsViewController.mainSegmentedControlHandler(_:)), for: .valueChanged)
    scrollView.addSubview(mainSegment)
    
  }
  
  @objc func shareButtonPressed(sender: UIView) {
    UIGraphicsBeginImageContext(scrollView.frame.size)
    scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
    UIGraphicsEndImageContext()
    
    let problemToShare = [BPM.stringifyProblems(startIdx: 0, endIdx: BPM.getNumKnownProblems() - 1)] as [Any]
    let activityVC = UIActivityViewController(activityItems: problemToShare, applicationActivities: nil)
    //Excluded Activities
    activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
    activityVC.popoverPresentationController?.sourceView = sender
    present(activityVC, animated: true, completion: nil)
  }

  //MARK: - Handle main segmented control.
  @objc func mainSegmentedControlHandler(_ sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0: // Cancel
//      getBlockProblem().clean(oldIdx: getBlockProblem().getKnownProblemIdx(), shapes: &Shapes)
//      setColorPickerVisibility(isHidden: true)
//      cleanOverlays()
      let overlayMode = false
      break
    case 1: // Submit
      let overlay = true
      break
    default:
      break
    }
  }
}
