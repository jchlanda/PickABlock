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
    getBlockProblemManager().displayKnownProblem(view: self.zoomView, problemIdx: 0, shapes: &Shapes)
    mainSegment.addTarget(self, action: #selector(BrowseView.mainSegmentedControlHandler(_:)), for: .valueChanged)
    superview?.addSubview(mainSegment)

    nextButton.setUpLayer(button: nextButton, displayName: "<", x: 0, y: Int(frame.maxY / 2 + yOffset), width: 35, height: 35)
    prevButton.setUpLayer(button: prevButton, displayName: ">", x: Int(frame.maxX - 35), y: Int(frame.maxY / 2 + yOffset), width: 35, height: 35)
    nextButton.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
    prevButton.addTarget(self, action: #selector(prevButtonAction), for: .touchUpInside)

    superview?.addSubview(nextButton)
    superview?.addSubview(prevButton)
    setTitle()
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
    let canDelete = getBlockProblemManager().canDeleteProblem()
    let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
    alertController.view.tintColor = Defs.RedStroke

    if canDelete {
      alertController.title = "Are you sure you want to delete a problem?"
      let okAction = UIAlertAction(title: "OK", style: .default, handler: { (pAction) in
        self.getBlockProblemManager().deleteProblem()
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
