//
//  AddGroupUsersViewController.swift
//  Payback
//
//  Created by Anya McGee on 2015-12-12.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class AddGroupUsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var userData: [User]?
    var group: Group?
    
    var addedUsers: [User]? = [User]()
    var alreadyExisting: [User]? = [User]()
    
    let foundAllUsers = dispatch_group_create()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "done:")
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.leftBarButtonItem?.title = ""

        //handleFetch()
        CurrentUser.sharedInstance.getUserFriends({(result: [User]?) in
            self.userData = result
        })

    }
    
    func handleFetch() {
        findFirstUsers()
        findSecondUsers()
        self.userData = [User]()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            dispatch_group_wait(self.foundAllUsers, DISPATCH_TIME_FOREVER)
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        })
    }
    
    func findFirstUsers() {
        dispatch_group_enter(foundAllUsers)
        let query: IBMQuery = IBMQuery(forClass: "Friendship")
        query.whereKey("firstUser", equalTo: CurrentUser.sharedInstance.currentUser)
        query.find().continueWithBlock({(task: BFTask!) -> BFTask! in
            if let results = task.result() as? [Friendship] {
                for result in results {
                    print(result)
                    self.userData?.append(result.secondUser)
                    dispatch_group_enter(self.foundAllUsers)
                    result.secondUser.fetchIfNecessary().continueWithBlock({(task: BFTask!) -> BFTask! in
                        dispatch_group_leave(self.foundAllUsers)
                        return nil
                    })
                }
            }
            dispatch_group_leave(self.foundAllUsers)
            return nil
        })
    }
    
    func findSecondUsers() {
        dispatch_group_enter(foundAllUsers)
        let query: IBMQuery = IBMQuery(forClass: "Friendship")
        query.whereKey("secondUser", equalTo: CurrentUser.sharedInstance.currentUser)
        query.find().continueWithBlock({(task: BFTask!) -> BFTask! in
            if let results = task.result() as? [Friendship] {
                for result in results {
                    print(result)
                    self.userData?.append(result.firstUser)
                    dispatch_group_enter(self.foundAllUsers)
                    result.firstUser.fetchIfNecessary().continueWithBlock({(task: BFTask!) -> BFTask! in
                        dispatch_group_leave(self.foundAllUsers)
                        return nil
                    })
                }
            }
            dispatch_group_leave(self.foundAllUsers)
            return nil
        })
    }
    
    func done(sender: AnyObject?) {
        self.navigationItem.rightBarButtonItem?.enabled = false
        if let addedUsers = self.addedUsers {
            let addUsersGroup = dispatch_group_create()
            
            var infos = [UserGroupInfo]()
            for user in addedUsers {
                let info = UserGroupInfo()
                info.user = user
                info.username = user.name
                info.group = group!
                info.balance = 0
                infos.append(info)
                
                dispatch_group_enter(addUsersGroup)
                info.save().continueWithBlock({(task: BFTask!) -> BFTask! in
                    dispatch_group_leave(addUsersGroup)
                    if task.error() == nil {
                        print("saved successfully")
                    } else {
                        print(task.error())
                    }
                    return nil
                })
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
                    dispatch_group_wait(addUsersGroup, DISPATCH_TIME_FOREVER)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.navigationItem.rightBarButtonItem?.enabled = true
                        if self.navigationController?.viewControllers != nil {
                            for controller in (self.navigationController?.viewControllers)! {
                                if let vc = controller as? MyGroupsViewController {
                                    self.navigationController?.popToViewController(vc, animated: true)
                                }
                            }
                        }
                    })
                })
            }
        } else {
            for controller in (self.navigationController?.viewControllers)! {
                if let vc = controller as? MyGroupsViewController {
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userData?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.userData != nil && indexPath.row < self.userData!.count {
            if let cell = self.tableView.dequeueReusableCellWithIdentifier("userCell") as? UserTableViewCell {
                cell.user = self.userData?[indexPath.row]
                return cell
            } else {
                let cell = UserTableViewCell()
                cell.user = self.userData?[indexPath.row]
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let user = self.userData?[indexPath.row] {
            if self.addedUsers?.contains(user) == true {
                self.addedUsers?.removeAtIndex((self.addedUsers?.indexOf(user))!)
                let cell = self.tableView.cellForRowAtIndexPath(indexPath)
                cell?.accessoryType = UITableViewCellAccessoryType.None
            } else if self.alreadyExisting?.contains(user) == true {
                // do nothing
            } else {
                self.addedUsers?.append(user)
                let cell = self.tableView.cellForRowAtIndexPath(indexPath)
                cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
        }
    }
    
    func displayAlert(title: String, message: String, callback: (() -> ())) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction) in self.dismissViewControllerAnimated(true, completion: callback)})
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? UserTableViewCell {
            if self.addedUsers?.contains(cell.user!) == true || self.alreadyExisting?.contains(cell.user!) == true {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
    }
    
}
