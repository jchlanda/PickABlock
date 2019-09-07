//
//  SettingsViewController.swift
//  Block
//
//  Created by Jakub on 18/03/2019.
//  Copyright © 2019 Jakub. All rights reserved.
//

import UIKit

class SettingsViewController: ViewController, UITextViewDelegate {
  var scrollView: UIScrollView!

  var userLocalProblemsTextField = UITextView()
  var AMTV = UITextView()
  var UATV = UITextView()
  var AM = UIButton()
  var SA = UIButton()

  var CTV = UITextView()
  var C = UIButton()

  lazy var yOffset = UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.height)!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    hideKeyboardWhenTappedAround()
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
  
    let screensize: CGRect = UIScreen.main.bounds
    let screenWidth = screensize.width
    let screenHeight = screensize.height
    var scrollView: UIScrollView!
    scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))

    let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.shareButtonPressed))
    let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
    navigationController!.viewControllers[1].navigationItem.rightBarButtonItem = shareButton

    let textFieldY = (self.view.frame.maxY - yOffset - CGFloat(7 * 10 + 3 * 10 + 4 * 35)) / 3 // 7 offsets, 3 extra offsets and 4 buttons

    var yUsed = 10
    let UDP = UILabel(frame: CGRect(x: 10, y: yUsed, width: 220, height: 35))
    UDP.text = "User Defined Problems:"
    scrollView.addSubview(UDP)
    yUsed += 35
    userLocalProblemsTextField = getTextView(frame: CGRect(x: 10, y: CGFloat(yUsed), width: self.view.frame.maxX - 2 * 10 , height: textFieldY), placecholder: "User Local Problems")
    if (BPM.hasUserLocalProblems()) {
      userLocalProblemsTextField.text = BPM.stringifyProblems(startIdx: BPM.getUserLocalStartIdx(), endIdx: BPM.getNumKnownProblems() - 1)
    }
    scrollView.addSubview(userLocalProblemsTextField)
    yUsed += Int(textFieldY)
    yUsed += 10
    yUsed += 10

    let BIP = UILabel(frame: CGRect(x: 10, y: yUsed, width: 220, height: 35))
    BIP.text = "Build In Problems:"
    scrollView.addSubview(BIP)
    yUsed += 35
    let buildInProblems = getTextView(frame: CGRect(x: 10, y: CGFloat(yUsed), width: self.view.frame.maxX - 2 * 10 , height: textFieldY), placecholder: "Build In Problems")
    buildInProblems.text = BPM.stringifyProblems(startIdx: 0, endIdx: BPM.getUserLocalStartIdx() - 1)
    scrollView.addSubview(buildInProblems)
    yUsed += Int(textFieldY)
    yUsed += 10
    yUsed += 10
    yUsed += 10

    let CL = UILabel(frame: CGRect(x: 10, y: yUsed, width: 220, height: 35))
    CL.text = "Edit notes:"
    scrollView.addSubview(CL)
    yUsed += 35
    CTV = getTextView(frame: CGRect(x: 10, y: CGFloat(yUsed), width: self.view.frame.maxX - 2 * 10 , height: textFieldY), placecholder: "Update notes")
    CTV.delegate = self
    CTV.text = BPM.stringifyProblemsInfo()
    scrollView.addSubview(CTV)
    yUsed += Int(textFieldY)
    yUsed += 10
    C.setUpLayer(button: C, displayName: "Submit", x: 10, y: yUsed, width: 220, height: 35)
    C.addTarget(self, action: #selector(editNotesAction), for: .touchUpInside)
    scrollView.addSubview(C)
    yUsed += 35
    yUsed += 10
    yUsed += 10

    let AML = UILabel(frame: CGRect(x: 10, y: yUsed, width: 220, height: 35))
    AML.text = "Add problems manually:"
    scrollView.addSubview(AML)
    yUsed += 35
    AMTV = getTextView(frame: CGRect(x: 10, y: CGFloat(yUsed), width: self.view.frame.maxX - 2 * 10 , height: textFieldY), placecholder: "Add problems manually")
    AMTV.delegate = self
    scrollView.addSubview(AMTV)
    yUsed += Int(textFieldY)
    yUsed += 10
    AM.setUpLayer(button: AM, displayName: "Submit", x: 10, y: yUsed, width: 220, height: 35)
    AM.addTarget(self, action: #selector(addManuallyAction), for: .touchUpInside)
    scrollView.addSubview(AM)
    yUsed += 35
    yUsed += 10
    yUsed += 10

    let UAL = UILabel(frame: CGRect(x: 10, y: yUsed, width: 220, height: 35))
    UAL.text = "Update all:"
    scrollView.addSubview(UAL)
    yUsed += 35
    UATV = getTextView(frame: CGRect(x: 10, y: CGFloat(yUsed), width: self.view.frame.maxX - 2 * 10 , height: textFieldY), placecholder: "Update all")
    UATV.delegate = self
    scrollView.addSubview(UATV)
    yUsed += Int(textFieldY)
    yUsed += 10
    SA.setUpLayer(button: SA, displayName: "Submit", x: 10, y: yUsed, width: 220, height: 35)
    SA.addTarget(self, action: #selector(updateAll), for: .touchUpInside)
    scrollView.addSubview(SA)
    yUsed += 35
    yUsed += 10
    yUsed += 10

    let PDL = UILabel(frame: CGRect(x: 10, y: yUsed, width: 220, height: 35))
    PDL.text = "Purge duplicates:"
    scrollView.addSubview(PDL)
    yUsed += 35
    let PD = UIButton()
    PD.setUpLayer(button: PD, displayName: "Submit", x: 10, y: yUsed, width: 220, height: 35)
    PD.addTarget(self, action: #selector(purgeDuplicatesAction), for: .touchUpInside)
    scrollView.addSubview(PD)
    yUsed += 35
    yUsed += 10
    yUsed += 10

    scrollView.contentSize = CGSize(width: screenWidth, height: CGFloat(yUsed))
    view.addSubview(scrollView)
  }

  func getTextView(frame: CGRect, placecholder: String) -> UITextView {
    let tv = UITextView(frame: frame)
    tv.font = UIFont.systemFont(ofSize: 15)
    tv.layer.borderColor = Defs.DarkRed.cgColor
    tv.layer.cornerRadius = 15.0
    tv.layer.borderWidth = 1.0
    tv.tintColor = Defs.DarkRed
    tv.keyboardType = UIKeyboardType.default
    tv.returnKeyType = UIReturnKeyType.done
    tv.textContainer.lineBreakMode = .byCharWrapping

    return tv
  }

  @objc func editNotesAction(_ sender: Any) {
    let title = BPM.updateProblemInfo(info: CTV.text!)
    let alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
    alertController.view.tintColor = Defs.RedStroke
    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (pAction) in
      alertController.dismiss(animated: true, completion: nil)
    }))
    CTV.text = BPM.stringifyProblemsInfo()
    present(alertController, animated: true, completion: nil)
  }

  @objc func addManuallyAction(_ sender: Any) {
    let title = BPM.addManually(problems: AMTV.text!)
    let alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
    alertController.view.tintColor = Defs.RedStroke
    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (pAction) in
      alertController.dismiss(animated: true, completion: nil)
    }))
    present(alertController, animated: true, completion: nil)
  }

  @objc func updateAll(_ sender: Any) {
    let title = BPM.updateAll(info: UATV.text!)
    let alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
    alertController.view.tintColor = Defs.RedStroke
    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (pAction) in
      alertController.dismiss(animated: true, completion: nil)
    }))
    present(alertController, animated: true, completion: nil)
  }

  @objc func purgeDuplicatesAction(_ sender: Any) {
    let numPurged = BPM.purgeDuplicates()
    var title = ""
    if (0 == numPurged) {
      title = "No duplicates found."
    } else {
      title = "Purged " + String(numPurged) + " duplicate"
      if (numPurged > 1) {
        title += "s."
      } else {
        title += "."
      }
      userLocalProblemsTextField.text = BPM.stringifyProblems(startIdx: BPM.getUserLocalStartIdx(), endIdx: BPM.getNumKnownProblems() - 1)
    }
    let alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
    alertController.view.tintColor = Defs.RedStroke
    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (pAction) in
      alertController.dismiss(animated: true, completion: nil)
    }))
    present(alertController, animated: true, completion: nil)
  }

  func getAllData() -> String {
    let userLocalIdx = BPM.getUserLocalStartIdx()
    var allData = BPM.getTimeStamp()
    allData.append("\nBuild In Problems:\n")
    allData.append(BPM.stringifyProblems(startIdx: 0, endIdx: userLocalIdx - 1))
    allData.append("\n\nUser Local Problems:\n")
    allData.append(BPM.stringifyProblems(startIdx: userLocalIdx, endIdx: BPM.getNumKnownProblems() - 1))
    allData.append("\n\nProblems Info:\n")
    allData.append(BPM.stringifyProblemsInfo())

    return allData
  }

  @objc func shareButtonPressed(sender: UIView) {
    let toShare = getAllData()
    let problemToShare = [toShare] as [Any]
    let activityVC = UIActivityViewController(activityItems: problemToShare, applicationActivities: nil)
    //Excluded Activities
    activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
    activityVC.popoverPresentationController?.sourceView = sender
    present(activityVC, animated: true, completion: nil)
  }

  @objc func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
      if self.view.frame.origin.y == 0 {
        self.view.frame.origin.y -= keyboardSize.height
      }
    }
  }
  
  @objc func keyboardWillHide(notification: NSNotification) {
    if self.view.frame.origin.y != 0 {
      self.view.frame.origin.y = 0
    }
  }
}

extension UIViewController {
  func hideKeyboardWhenTappedAround() {
    let tapGesture = UITapGestureRecognizer(target: self,
                                            action: #selector(hideKeyboard))
    view.addGestureRecognizer(tapGesture)
  }
  
  @objc func hideKeyboard() {
    view.endEditing(true)
  }
}
