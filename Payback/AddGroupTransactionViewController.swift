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
    
    var totalGroupBalance: Float = 0.0
    var totalMyBalance: Float = 0.0
    var amount: Float = 0.0
    
    var group: Group?
    var userInfo: UserGroupInfo?
    var newTransaction: GroupTransaction?

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let newTransaction = GroupTransaction()
        newTransaction.reason = self.reasonTextField.text
        var multiplier: Float = 1.0
        if self.plusMinusSegControl.selectedSegmentIndex == 1 {
            multiplier = -1.0
        }
        newTransaction.amount = self.amount * multiplier
        newTransaction.group = self.group!
        newTransaction.user = CurrentUser.sharedInstance.currentUser!
        print(newTransaction.amount)
        newTransaction.save().continueWithBlock({(task: BFTask!) -> BFTask! in
            print("saved")
            self.newTransaction = newTransaction
            if self.plusMinusSegControl.selectedSegmentIndex == 1 {
                self.group?.balance += self.amount
                self.group?.save().continueWithBlock({(tasl: BFTask!) -> BFTask! in
                    self.navigateAway()
                    return nil
                })
            } else {
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
