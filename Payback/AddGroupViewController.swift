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
        
        self.iconImageView.layer.borderColor = Style.mossGreen.CGColor
        self.iconImageView.layer.borderWidth = 1.0
        
        self.descriptionTextField.layer.borderColor = Style.mossGreen.CGColor
        self.descriptionTextField.layer.borderWidth = 1.0
        
        self.nameTextField.layer.borderColor = Style.mossGreen.CGColor
        self.nameTextField.layer.borderWidth = 1.0
        let str = NSAttributedString(string: "Group Name", attributes: [NSForegroundColorAttributeName:Style.lightGreen])
        self.nameTextField.attributedPlaceholder = str
        
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
            newGroup.balance = 0
            newGroup.detail = descriptionTextField.text
            newGroup.icon = self.iconName
            newGroup.author = CurrentUser.sharedInstance.currentUser!
            newGroup.save().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
                self.performSegueWithIdentifier("showAddUsers", sender: newGroup)
                return nil
            })
            
            let info = UserGroupInfo()
            info.group = newGroup
            info.user = newGroup.author
            info.username = newGroup.author.name
            info.balance = 0
            info.save().continueWithBlock({(task: BFTask!) -> BFTask! in
                print("Successfully added author as group member")
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
