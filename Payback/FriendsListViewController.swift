//
//  FriendsListViewController.swift
//  Payback
//
//  Created by Alice Fredine on 2015-12-13.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class FriendsListViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var friendData: [Friendship]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.r
        tableView.delegate = self
        tableView.dataSource = self
        
        CurrentUser.sharedInstance.getFriendsData({(_: [User]?, result: [Friendship]?) in
                self.friendData = result
                self.tableView.reloadData()
            })
        
        /**
        let queryUserGroup = dispatch_group_create()
        
        dispatch_group_enter(queryUserGroup)
        let query: IBMQuery = IBMQuery(forClass: "Friendship")
        query.whereKey("firstUserEmail", equalTo: CurrentUser.sharedInstance.currentUser!.email)
        query.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if let results = task.result() as? [Friendship] {
                self.friendData = results
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendData?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.friendData != nil && indexPath.row < self.friendData!.count {
            if let cell = self.tableView.dequeueReusableCellWithIdentifier("friendCell") as? FriendCell {
                let friendship: Friendship = (self.friendData?[indexPath.row])!
                if (friendship.secondUserEmail == CurrentUser.sharedInstance.currentUser!.email) {
                    cell.friend = self.friendData?[indexPath.row].firstUser
                }
                else {
                    cell.friend = self.friendData?[indexPath.row].secondUser
                }
                cell.friendship = friendship
                return cell
            }
        }
        return UITableViewCell()
    }

}
