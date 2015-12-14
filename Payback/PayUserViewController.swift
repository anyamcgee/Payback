//
//  PayUserViewController.swift
//  Payback
//
//  Created by Alice Fredine on 2015-12-12.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class PayUserViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var friendData: [Friendship]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let queryUserGroup = dispatch_group_create()
        
        dispatch_group_enter(queryUserGroup)
        let query: IBMQuery = IBMQuery(forClass: "Friendship")
        query.whereKey("firstUserEmail", equalTo: CurrentUser.sharedInstance.currentUser!.email)
        query.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if var results = task.result() as? [Friendship] {
                for result in results {
                    if (result.firstUserScore >= 0) {
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
                    if (result.firstUserScore >= 0) {
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
    
    func refreshTableData() {
        let queryUserGroup = dispatch_group_create()
        
        dispatch_group_enter(queryUserGroup)
        let query: IBMQuery = IBMQuery(forClass: "Friendship")
        query.whereKey("firstUserEmail", equalTo: CurrentUser.sharedInstance.currentUser!.email)
        query.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if var results = task.result() as? [Friendship] {
                for result in results {
                    if (result.firstUserScore >= 0) {
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
                    if (result.firstUserScore >= 0) {
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
        return self.friendData?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.friendData != nil && indexPath.row < self.friendData!.count {
            if let cell = self.tableView.dequeueReusableCellWithIdentifier("payUserCell") as? PayUserCell {
                let friendship: Friendship = (self.friendData?[indexPath.row])!
                if (friendship.secondUserEmail == CurrentUser.sharedInstance.currentUser!.email) {
                    cell.user = self.friendData?[indexPath.row].firstUser
                    cell.score = self.friendData?[indexPath.row].secondUserScore
                }
                else {
                    cell.user = self.friendData?[indexPath.row].secondUser
                    cell.score = self.friendData?[indexPath.row].firstUserScore
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let friendship: Friendship = (self.friendData?[indexPath.row])!
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

    func displayPayUserPopup(user: User, score: Float) {
        var alertController = UIAlertController(title: "Pay " + user.name, message: "", preferredStyle: .Alert)
        
        
        var amountTextEnter = UITextField()
        var descriptionTextEnter = UITextField()
        
        // Create the actions
        var okAction = UIAlertAction(title: "Pay", style: UIAlertActionStyle.Default) {
            UIAlertAction in
                        Transaction.CreateTransaction(user, from: CurrentUser.sharedInstance.currentUser!, amount: (amountTextEnter.text! as NSString).floatValue, description: descriptionTextEnter.text)
            self.refreshTableData()
            NSLog("OK Pressed")
        }
        
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        alertController.addTextFieldWithConfigurationHandler({(amountTextEnter) -> Void in
            amountTextEnter.placeholder = "Amount"
            amountTextEnter.backgroundColor = Style.lightGreen
        })
        alertController.addTextFieldWithConfigurationHandler({(descriptionTextEnter) -> Void in
            descriptionTextEnter.placeholder = "Description"
            descriptionTextEnter.backgroundColor = Style.lightGreen
        })
        
        // Present the controller
        self.presentViewController(alertController, animated: true, completion: nil)

    }
}
