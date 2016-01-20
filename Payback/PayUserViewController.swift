//
//  PayUserViewController.swift
//  Payback
//
//  Created by Alice Fredine on 2015-12-12.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class PayUserViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var friendData: [Friendship]?
    var displayData: [Friendship]?
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.center = self.view.center
        self.view.bringSubviewToFront(self.activityIndicator)
        self.activityIndicator.color = UIColor.grayColor()
        
        let queryUserGroup = dispatch_group_create()
        self.activityIndicator.startAnimating()
        dispatch_group_enter(queryUserGroup)
        let query: IBMQuery = IBMQuery(forClass: "Friendship")
        query.whereKey("firstUserEmail", equalTo: CurrentUser.sharedInstance.currentUser!.email)
        query.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if var results = task.result() as? [Friendship] {
                /**
                for result in results {
                    if (result.firstUserScore > 0) {
                        results.removeAtIndex(results.indexOf(result)!)
                    }
                }
                **/
                self.friendData = results
                self.displayData = results
            }
            dispatch_group_leave(queryUserGroup)
            return nil;
        })
        dispatch_group_enter(queryUserGroup)
        let secondQuery: IBMQuery = IBMQuery(forClass: "Friendship")
        secondQuery.whereKey("secondUserEmail", equalTo: CurrentUser.sharedInstance.currentUser!.email)
        secondQuery.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if var results = task.result() as? [Friendship] {
                /**
                for result in results {
                    if (result.secondUserScore > 0) {
                        results.removeAtIndex(results.indexOf(result)!)
                    }
                }
                **/
                self.friendData?.appendContentsOf(results)
                self.displayData?.appendContentsOf(results)
            }
            dispatch_group_leave(queryUserGroup)
            return nil;
        })
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
            dispatch_group_wait(queryUserGroup, DISPATCH_TIME_FOREVER)
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            })
        })
    }
    
    func refreshTableData() {
        let queryUserGroup = dispatch_group_create()
        
        dispatch_group_enter(queryUserGroup)
        let query: IBMQuery = IBMQuery(forClass: "Friendship")
        query.whereKey("firstUserEmail", equalTo: CurrentUser.sharedInstance.currentUser!.email)
        query.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if var results = task.result() as? [Friendship] {
                for result in results {
                    if (result.firstUserScore > 0) {
                        results.removeAtIndex(results.indexOf(result)!)
                    }
                }
                self.friendData = results
            }
            dispatch_group_leave(queryUserGroup)
            return nil;
        })
        dispatch_group_enter(queryUserGroup)
        let secondQuery: IBMQuery = IBMQuery(forClass: "Friendship")
        secondQuery.whereKey("secondUserEmail", equalTo: CurrentUser.sharedInstance.currentUser!.email)
        secondQuery.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if var results = task.result() as? [Friendship] {
                for result in results {
                    if (result.secondUserScore > 0) {
                        results.removeAtIndex(results.indexOf(result)!)
                    }
                }
                self.friendData?.appendContentsOf(results)
            }
            dispatch_group_leave(queryUserGroup)
            return nil;
        })
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
            dispatch_group_wait(queryUserGroup, DISPATCH_TIME_FOREVER)
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        })

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(self.displayData?.count ?? 1, 1)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.displayData != nil && indexPath.row < self.displayData!.count {
            if let cell = self.tableView.dequeueReusableCellWithIdentifier("payUserCell") as? PayUserCell {
                let friendship: Friendship = (self.displayData?[indexPath.row])!
                if (friendship.secondUserEmail == CurrentUser.sharedInstance.currentUser!.email) {
                    cell.user = self.displayData?[indexPath.row].firstUser
                    cell.score = self.displayData?[indexPath.row].secondUserScore
                }
                else {
                    cell.user = self.displayData?[indexPath.row].secondUser
                    cell.score = self.displayData?[indexPath.row].firstUserScore
                }
                return cell
            }
        } else {
            if let cell = self.tableView.dequeueReusableCellWithIdentifier("emptyCell") {
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < 0 || indexPath.row >= displayData?.count { return }
        
        let friendship: Friendship = (self.displayData?[indexPath.row])!
        var score: Float = 0.0
        var user: User = User()
        if (friendship.secondUserEmail == CurrentUser.sharedInstance.currentUser!.email) {
            user = friendship.firstUser
            score = friendship.secondUserScore
        }
        else {
            user = friendship.secondUser
            score = friendship.firstUserScore
        }
        
        displayPayUserPopup(user, score: score)
    }

    var amountTextEnter: UITextField!
    var descriptionTextEnter: UITextField!
    
    func configurationAmountTextField(textField: UITextField!)
    {
        print("generating the TextField")
        textField.placeholder = "Amount"
        textField.backgroundColor = Style.lightGreen
        amountTextEnter = textField
    }
    
    func configurationDescTextField(textField: UITextField!)
    {
        print("generating desc text field")
        textField.placeholder = "Description"
        textField.backgroundColor = Style.lightGreen
        descriptionTextEnter = textField
    }
    
    func displayPayUserPopup(user: User, score: Float) {
        var alertController = UIAlertController(title: "Pay " + user.name, message: "", preferredStyle: .Alert)
        
        // Create the actions
        var okAction = UIAlertAction(title: "Pay", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            // TODO: Add Caching here, see if this is where the score is breaking?
            Transaction.CreateTransaction(user, from: CurrentUser.sharedInstance.currentUser!, amount: (self.amountTextEnter.text! as NSString).floatValue, description: (self.descriptionTextEnter.text! as String), callback: { () -> Void in
                    self.tableView.reloadData()})
        }
        
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        alertController.addTextFieldWithConfigurationHandler(configurationAmountTextField)
        alertController.addTextFieldWithConfigurationHandler(configurationDescTextField)
        
        // Present the controller
        self.presentViewController(alertController, animated: true, completion: nil)

    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            filterFriends(searchText)
        } else {
            displayData = friendData
        }
        print("reloading table view")
        self.tableView.reloadData()
    }
    
    
    func filterFriends(searchText: String) {
        displayData = friendData?.filter{
            let friendship = ($0 as Friendship)
            if (friendship.secondUserEmail == CurrentUser.sharedInstance.currentUser!.email) {
                return
                    (friendship.firstUser.name.lowercaseString.containsString(searchText.lowercaseString) ||
                        friendship.firstUser.email.lowercaseString.containsString(searchText.lowercaseString))
            } else {
                return
                    (friendship.secondUser.name.lowercaseString.containsString(searchText.lowercaseString) ||
                        friendship.secondUser.email.lowercaseString.containsString(searchText.lowercaseString))
            }
        }
    }
}
