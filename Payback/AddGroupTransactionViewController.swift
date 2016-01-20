//
//  AddGroupTransactionViewController.swift
//  Payback
//
//  Created by Anya McGee on 2015-12-13.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class AddGroupTransactionViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var groupBalanceLabel: UILabel!
    @IBOutlet weak var yourBalanceLabel: UILabel!
    @IBOutlet weak var plusMinusSegControl: UISegmentedControl!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var reasonTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    var totalGroupBalance: Float = 0.0
    var totalMyBalance: Float = 0.0
    var amount: Float = 0.0
    
    var group: Group?
    var userInfo: UserGroupInfo?
    var newTransaction: GroupTransaction?
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func setUpActivityIndicator() {
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.center = self.view.center
        self.view.bringSubviewToFront(self.activityIndicator)
        self.activityIndicator.color = UIColor.grayColor()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpActivityIndicator()
        
        CurrentUser.sharedInstance.getUserInfo(forGroup: self.group!, callback: {(results: [UserGroupInfo]) in
            for result in results {
                if result.user.objectId == CurrentUser.sharedInstance.currentUser!.objectId {
                    self.userInfo = result
                }
            }
        })
        
        totalGroupBalance = group?.balance ?? 0
        totalMyBalance = userInfo?.balance ?? 0
        
        self.groupBalanceLabel.text = "\(totalGroupBalance)"
        self.yourBalanceLabel.text = "\(totalMyBalance)"
        
        self.amountTextField.delegate = self
        self.reasonTextField.delegate = self
        
        setLabels()
    }
    
    func setLabels() {
        let amount = NSString(string: self.amountTextField.text ?? "").floatValue
        self.amount = amount
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        setLabels()
        textField.resignFirstResponder()
    }
    
    @IBAction func done(sender: AnyObject) {
        if self.userInfo!.balance >= 0 && self.plusMinusSegControl.selectedSegmentIndex == 0 {
            self.displayAlert("Error", message: "You don't owe this group any money. Did you want to add a group expense?")
            self.plusMinusSegControl.selectedSegmentIndex = 1
            return
        }
        
        self.doneButton.enabled = false
        
        let newTransaction = GroupTransaction()
        newTransaction.reason = self.reasonTextField.text
        var multiplier: Float = 1.0
        if self.plusMinusSegControl.selectedSegmentIndex == 1 {
            multiplier = -1.0
        }
        newTransaction.amount = self.amount * multiplier
        
        // hacky but this may be crashing sometimes
        if (self.group == nil) { return }
        newTransaction.group = self.group!
        newTransaction.user = CurrentUser.sharedInstance.currentUser!
        CurrentUser.sharedInstance.addGroupTransaction(newTransaction)
        self.activityIndicator.startAnimating()
        newTransaction.save().continueWithBlock({(task: BFTask!) -> BFTask! in
            print("saved")
            self.doneButton.enabled = true
            self.newTransaction = newTransaction
            if self.plusMinusSegControl.selectedSegmentIndex == 1 {
                self.group?.balance += self.amount
                CurrentUser.sharedInstance.updateGroup(self.group!)
                self.group?.save().continueWithBlock({(task: BFTask!) -> BFTask! in
                    self.activityIndicator.stopAnimating()
                    self.navigateAway()
                    return nil
                })
            } else {
                self.activityIndicator.stopAnimating()
                self.navigateAway()
            }
            return nil
        })
    }
    
    func navigateAway() {
        self.performSegueWithIdentifier("showGroupDetail", sender: self)
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction) in self.dismissViewControllerAnimated(true, completion: nil)})
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text.containsString("\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destVC = segue.destinationViewController as? GroupDetailViewController {
            destVC.group = self.group
            destVC.didAddTransaction = self.newTransaction
        }
    }
}
