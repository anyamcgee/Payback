//
//  FriendsListViewController.swift
//  Payback
//
//  Created by Alice Fredine on 2015-12-13.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class FriendsListViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var requestsButton: UIBarButtonItem!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var friendData: [Friendship]?
    var displayData: [Friendship]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.r
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self

            
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.center = self.view.center
        self.view.bringSubviewToFront(self.activityIndicator)
        self.activityIndicator.color = UIColor.grayColor()

        
        /*self.activityIndicator.startAnimating()
        var hasFriends: Bool = false
        let friendGroup = dispatch_group_create()
        dispatch_group_enter(friendGroup)
        FriendRequest.checkFriendRequests(CurrentUser.sharedInstance.currentUser!, callback: {(results: [FriendRequest]?) -> Void in
            if (results?.count > 0) {
                hasFriends = true;
            }
            dispatch_group_leave(friendGroup)
        })
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            dispatch_group_wait(friendGroup, DISPATCH_TIME_FOREVER)
            dispatch_async(dispatch_get_main_queue(), {
                if (hasFriends) { // User has friend requests
                    // Show button if there are pending friend requests
                    self.requestsButton.enabled = true
                } else {
                    // hide button otherwise
                    self.requestsButton.enabled = false
                    self.requestsButton.tintColor = UIColor.clearColor()
                }
                CurrentUser.sharedInstance.getFriendsData({(_: [User]?, result: [Friendship]?) in
                    // self.activityIndicator.stopAnimating()
                    self.friendData = result
                    self.displayData = result
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                })

            })
        })*/
        /*CurrentUser.sharedInstance.getFriendsData({(_: [User]?, result: [Friendship]?) in
                // self.activityIndicator.stopAnimating()
                self.friendData = result
                self.displayData = result
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            })*/
        
        /**
        let queryUserGroup = dispatch_group_create()
        
        dispatch_group_enter(queryUserGroup)
        let query: IBMQuery = IBMQuery(forClass: "Friendship")
        query.whereKey("firstUserEmail", equalTo: CurrentUser.sharedInstance.currentUser!.email)
        query.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if let results = task.result() as? [Friendship] {
                self.friendData = results
                self.displayData = results
            }
            print("fetched first user data")
            dispatch_group_leave(queryUserGroup)
            return nil;
        })
        dispatch_group_enter(queryUserGroup)
        let secondQuery: IBMQuery = IBMQuery(forClass: "Friendship")
        secondQuery.whereKey("secondUserEmail", equalTo: CurrentUser.sharedInstance.currentUser!.email)
        secondQuery.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if let results = task.result() as? [Friendship] {
                self.friendData?.appendContentsOf(results)
                self.displayData?.appendContentsOf(results)
            }
            print("fetched user data")
            dispatch_group_leave(queryUserGroup)
            return nil;
        })
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
            dispatch_group_wait(queryUserGroup, DISPATCH_TIME_FOREVER)
            dispatch_async(dispatch_get_main_queue(), {
                print("reloading table view")
                            self.tableView.reloadData()
            })
        })
        **/
    }
    
    override func viewDidAppear(animated: Bool) {
        self.activityIndicator.startAnimating()
        var hasFriends: Bool = false
        let friendGroup = dispatch_group_create()
        dispatch_group_enter(friendGroup)
        FriendRequest.checkFriendRequests(CurrentUser.sharedInstance.currentUser!, callback: {(results: [FriendRequest]?) -> Void in
            if (results?.count > 0) {
                hasFriends = true;
            }
            dispatch_group_leave(friendGroup)
        })
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            dispatch_group_wait(friendGroup, DISPATCH_TIME_FOREVER)
            dispatch_async(dispatch_get_main_queue(), {
                if (hasFriends) { // User has friend requests
                    // Show button if there are pending friend requests
                    self.requestsButton.enabled = true
                } else {
                    // hide button otherwise
                    self.requestsButton.enabled = false
                    self.requestsButton.tintColor = UIColor.clearColor()
                }
                CurrentUser.sharedInstance.getFriendsData({(_: [User]?, result: [Friendship]?) in
                    // self.activityIndicator.stopAnimating()
                    self.friendData = result
                    self.displayData = result
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                })
                
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendData?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.displayData != nil && indexPath.row < self.displayData!.count {
            if let cell = self.tableView.dequeueReusableCellWithIdentifier("friendCell") as? FriendCell {
                let friendship: Friendship = (self.displayData?[indexPath.row])!
                if (friendship.secondUserEmail == CurrentUser.sharedInstance.currentUser!.email) {
                    cell.friend = self.displayData?[indexPath.row].firstUser
                }
                else {
                    cell.friend = self.displayData?[indexPath.row].secondUser
                }
                cell.friendship = friendship
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            filterFriends(searchText)
        } else {
            displayData = friendData
        }
        self.tableView.reloadData()
    }
    
    
    func filterFriends(searchText: String) {
        displayData = friendData?.filter{
            let friendship = ($0 as Friendship)
            if (friendship.secondUserEmail == CurrentUser.sharedInstance.currentUser!.email) {
                return
                    (//friendship.firstUserName.lowercaseString.containsString(searchText.lowercaseString) ||
                     friendship.firstUserEmail.lowercaseString.containsString(searchText.lowercaseString))
            } else {
                return
                    (//friendship.secondUserName.lowercaseString.containsString(searchText.lowercaseString) ||
                     friendship.secondUserEmail.lowercaseString.containsString(searchText.lowercaseString))
            }
        }
    }
    

}
