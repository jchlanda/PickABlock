//
//  BrowseView.swift
//  Block
//
//  Created by Jakub on 11/03/2019.
//  Copyright © 2019 Jakub. All rights reserved.
//

import UIKit

class BrowseView: ImageScrollView {

  lazy var mainSegment: UISegmentedControl = Defs.setUpSegmentedControl(frame: self.frame, elements: ["Edit", "Delete"], yOffset: yOffset)

  var nextButton = UIButton()
  var prevButton = UIButton()

  override func display(_ image: UIImage) {
    super.display(image)
    if (getBlockProblemManager().getNumKnownProblems() == 0) {
      showNoProblemsAlert()
      return
    }
    getBlockProblemManager().displayKnownProblem(view: self.zoomView, problemIdx: getBlockProblemManager().getKnownProblemIdx(), shapes: &Shapes)
    mainSegment.addTarget(self, action: #selector(BrowseView.mainSegmentedControlHandler(_:)), for: .valueChanged)
    superview?.addSubview(mainSegment)

    nextButton.setUpLayer(button: nextButton, displayName: "<", x: 0, y: Int(frame.maxY / 2 + yOffset), width: 35, height: 35)
    prevButton.setUpLayer(button: prevButton, displayName: ">", x: Int(frame.maxX - 35), y: Int(frame.maxY / 2 + yOffset), width: 35, height: 35)
    nextButton.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
    prevButton.addTarget(self, action: #selector(prevButtonAction), for: .touchUpInside)

    superview?.addSubview(nextButton)
    superview?.addSubview(prevButton)
    setTitle()
    let share = navigationController!.viewControllers[1].navigationItem.rightBarButtonItems![0]
    let commentButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action:
        #selector(self.commentButtonPressed))
        // #selector(self.shareButtonPressed2))

    navigationController!.viewControllers[1].navigationItem.rightBarButtonItems = [share, commentButton]
  }
  
  func showNoProblemsAlert() {
    let alertController = UIAlertController(title: "No problems created yet.", message: "", preferredStyle: .alert)
    alertController.view.tintColor = Defs.RedStroke

    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (pAction) in
      alertController.dismiss(animated: true, completion: nil)
    }))
    let vc = findViewController()
    vc?.present(alertController, animated: true, completion: nil)
  }

  func showCommentDialogue() {
    var textField: UITextField?
    let title = getBlockProblemManager().getKnownProblemName()
    let message = getBlockProblemManager().getKnownProblemInfo()
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.view.tintColor = Defs.RedStroke

    alertController.addTextField { (pTextField) in
      pTextField.text = "[" + self.getBlockProblemManager().getTimeStamp() + "] "
      pTextField.placeholder = "Add info."
      pTextField.clearButtonMode = .whileEditing
      pTextField.borderStyle = .none
      pTextField.addTarget(self, action: #selector(self.alertTextFieldDidChange(field:)), for: UIControl.Event.editingChanged)
      textField = pTextField
    }
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (pAction) in
      alertController.dismiss(animated: true, completion: nil)
    }))
    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (pAction) in
      let info = textField?.text ?? ""
      self.getBlockProblemManager().addKnownProblemInfo(info: info)
      alertController.dismiss(animated: true, completion: nil)
    })
    okAction.isEnabled = false
    alertController.addAction(okAction)
    let vc = findViewController()
    vc?.present(alertController, animated: true, completion: nil)
  }

  @objc func commentButtonPressed(sender: UIView) {
    showCommentDialogue()
  }

  @objc func nextButtonAction() {
    getBlockProblemManager().displayNextKnownProblem(view: self.zoomView, shapes: &Shapes)
    setTitle()
  }

  @objc func prevButtonAction() {
    getBlockProblemManager().displayPrevKnownProblem(view: self.zoomView, shapes: &Shapes)
    setTitle()
  }

  func confirmDelete() {
    let canDelete = getBlockProblemManager().isUserDefined()
    let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
    alertController.view.tintColor = Defs.RedStroke

    if canDelete {
      alertController.title = "Are you sure you want to delete a problem?"
      let okAction = UIAlertAction(title: "OK", style: .default, handler: { (pAction) in
        self.getBlockProblemManager().deleteCurrentProblem()
        if (self.getBlockProblemManager().getNumKnownProblems() == 0) {
          self.showNoProblemsAlert()
          return
        }
        self.nextButtonAction()
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

    let vc = findViewController()
    vc?.present(alertController, animated: true, completion: nil)
  }

  func setTitle() {
    navigationController!.viewControllers[1].navigationItem.title = getBlockProblemManager().getKnownProblemName()
  }

  @objc func mainSegmentedControlHandler(_ sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0: // Edit
      var newViewControllers = navigationController!.viewControllers
      let newView = SetViewController()
      newView.view.backgroundColor = Defs.White
      newView.navigationItem.title = "Set"
      newView.setEditState(knownProblemsIdx: getBlockProblemManager().getKnownProblemIdx())
      newViewControllers[1] = newView
      navigationController!.setViewControllers(newViewControllers, animated: true)
    case 1: // Delete
      confirmDelete()
    default:
      break
    }
  }
}
