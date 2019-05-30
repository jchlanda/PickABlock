//
//  SettingsViewController.swift
//  Block
//
//  Created by Jakub on 18/03/2019.
//  Copyright © 2019 Jakub. All rights reserved.
//

import UIKit

class SettingsViewController: ViewController, UITextViewDelegate {
  var userLocalProblemsTextField = UITextView()
  var AMTV = UITextView()
  var AM = UIButton()

  let scrollView: UIScrollView = {
    let v = UIScrollView()
    v.translatesAutoresizingMaskIntoConstraints = false
    return v
  }()

  lazy var yOffset = UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.height)!

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.addSubview(scrollView)

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

    AMTV = getTextView(frame: CGRect(x: 10, y: CGFloat(yUsed), width: self.view.frame.maxX - 2 * 10 , height: textFieldY), placecholder: "Add manually")
    AMTV.delegate = self
    scrollView.addSubview(AMTV)
    yUsed += Int(textFieldY)
    yUsed += 10
    AM.setUpLayer(button: AM, displayName: "Add manually", x: 10, y: yUsed, width: 220, height: 35)
    AM.addTarget(self, action: #selector(addManuallyAction), for: .touchUpInside)
    AM.isEnabled = false
    scrollView.addSubview(AM)
    yUsed += 35
    yUsed += 10
    yUsed += 10

    let PD = UIButton()
    PD.setUpLayer(button: PD, displayName: "Purge duplicates", x: 10, y: yUsed, width: 220, height: 35)
    PD.addTarget(self, action: #selector(purgeDuplicatesAction), for: .touchUpInside)
    scrollView.addSubview(PD)

    scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
    scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
    scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
    scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
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

  func textViewDidChange(_ textView: UITextView){
    AM.isEnabled = (textView.text?.count)! >= 1;
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

  @objc func shareButtonPressed(sender: UIView) {
    UIGraphicsBeginImageContext(scrollView.frame.size)
    scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
    UIGraphicsEndImageContext()

    let userLocalIdx = BPM.getUserLocalStartIdx()
    var toShare = "Build In Problems:\n["
    toShare.append(BPM.stringifyProblems(startIdx: 0, endIdx: userLocalIdx - 1))
    toShare.append("]\n\nUser Local Problems:\n[")
    toShare.append(BPM.stringifyProblems(startIdx: userLocalIdx, endIdx: BPM.getNumKnownProblems() - 1))
    toShare.append("]")
    let problemToShare = [toShare] as [Any]
    let activityVC = UIActivityViewController(activityItems: problemToShare, applicationActivities: nil)
    //Excluded Activities
    activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
    activityVC.popoverPresentationController?.sourceView = sender
    present(activityVC, animated: true, completion: nil)
  }
}
