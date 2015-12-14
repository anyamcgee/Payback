//
//  AddFriendsViewController.swift
//  Payback
//
//  Created by Alice Fredine on 2015-12-13.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class AddFriendsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var userData: [User]?
    
    var addedUsers: [User]? = [User]()
    
    var requestedUsers: [User]? = [User]()
    
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.r
        
        self.activityIndicator = UIActivityIndicatorView()
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.center = self.view.center
        self.view.bringSubviewToFront(self.activityIndicator)
        self.activityIndicator.color = UIColor.grayColor()
        
        tableView.delegate = self   
        tableView.dataSource = self
        
        let queryGroup = dispatch_group_create()
        self.activityIndicator.startAnimating()
        dispatch_group_enter(queryGroup)
        let query: IBMQuery = IBMQuery(forClass: "User")
        query.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            let result = task.result() as? [User]
            self.userData = result
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            dispatch_group_leave(queryGroup)
            return nil
        })
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
            dispatch_group_wait(queryGroup, DISPATCH_TIME_FOREVER)
            dispatch_async(dispatch_get_main_queue(), {
                self.checkForAlreadyFriends()
                self.checkForPendingRequests()
            })
        })
        
    }
    
    func checkForAlreadyFriends() {
        let queryGroup = dispatch_group_create()
        dispatch_group_enter(queryGroup)
        let query: IBMQuery = IBMQuery(forClass: "Friendship")
        query.whereKey("firstUserEmail", equalTo: CurrentUser.sharedInstance.currentUser?.email)
        query.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if let results = task.result() as? [Friendship] {
                for result in results {
                    if ((self.addedUsers?.contains(result.secondUser)) != false) {
                        self.addedUsers?.append(result.secondUser)
                    }
                }
            }
            dispatch_group_leave(queryGroup)
            return nil;
        })
        
        dispatch_group_enter(queryGroup)
        let secondQuery: IBMQuery = IBMQuery(forClass: "Friendship")
        secondQuery.whereKey("secondUserEmail", equalTo: CurrentUser.sharedInstance.currentUser?.email)
        secondQuery.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if let results = task.result() as? [Friendship] {
                for result in results {
                    if ((self.addedUsers?.contains(result.firstUser)) != false) {
                        self.addedUsers?.append(result.firstUser)
                    }
                }
            }
            dispatch_group_leave(queryGroup)
            return nil;
        })
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
            dispatch_group_wait(queryGroup, DISPATCH_TIME_FOREVER)
            dispatch_async(dispatch_get_main_queue(), {
                for user in (self.addedUsers)! {
                    print(user)
                    if ((self.userData?.contains(user)) != false) {
                        print(self.userData?.contains(user))
                        print(self.userData?.indexOf(user))
                        self.userData?.removeAtIndex((self.addedUsers?.indexOf(user))!)
                    }
                }
                self.tableView.reloadData()
                
            })
        })
    }
    
    func checkForPendingRequests() {
        let query: IBMQuery = IBMQuery(forClass: "FriendRequest")
        requestedUsers = [User]()
        query.whereKey("fromEmail", equalTo: CurrentUser.sharedInstance.currentUser?.email)
        query.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if let results = task.result() as? [FriendRequest] {
                for result in results {
                    self.requestedUsers?.append(result.toUser)
                }
            }
            self.tableView.reloadData()
            return nil;
        })

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userData?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.userData != nil && indexPath.row < self.userData!.count {
            if let cell = self.tableView.dequeueReusableCellWithIdentifier("addFriendCell") as? AddFriendCell {
                cell.user = self.userData?[indexPath.row]
                if ((requestedUsers?.contains(cell.user!)) != false) {
                    cell.backgroundColor = Style.brown
                    cell.sendRequestButton.enabled = false
                }
                return cell
            } else {
                let cell = AddFriendCell()
                cell.user = self.userData?[indexPath.row]
                return cell
            }
        }
        return UITableViewCell()
    }

}
