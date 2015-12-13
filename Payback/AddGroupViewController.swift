//
//  AddGroupViewController.swift
//  Payback
//
//  Created by Anya McGee on 2015-12-12.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class AddGroupViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var iconImageView: UIImageView!
    var iconName: String?
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Create a New Group"
        
        self.descriptionTextField.delegate = self
        self.nameTextField.delegate = self
        self.descriptionTextField.returnKeyType = UIReturnKeyType.Done
        self.nameTextField.returnKeyType = UIReturnKeyType.Done
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "Description" {
            textView.text = ""
        }
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

    @IBAction func next(sender: AnyObject) {
        if nameTextField.text == nil || nameTextField.text?.characters.count == 0 {
            self.showAlert("Error", message: "Your group must have a title")
        } else {
            let newGroup = Group()
            newGroup.name = nameTextField.text!
            newGroup.detail = descriptionTextField.text
            newGroup.icon = self.iconName
            newGroup.author = CurrentUser.sharedInstance.currentUser!
            // newGroup.author = get the current user
            newGroup.save().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
                self.performSegueWithIdentifier("showAddUsers", sender: newGroup)
                return nil
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSelectIcon" {
            if let vc = segue.destinationViewController as? AddIconViewController {
                vc.addGroupVC = self
            }
        } else if segue.identifier == "showAddUsers" {
            if let vc = segue.destinationViewController as? AddGroupUsersViewController {
                if let group = sender as? Group {
                    vc.group = group
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        
    }
}
