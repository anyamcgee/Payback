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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.r
        
        tableView.delegate = self   
        tableView.dataSource = self
        
        let query: IBMQuery = IBMQuery(forClass: "User")
        query.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            let result = task.result() as? [User]
            self.userData = result
            self.tableView.reloadData()
            return nil
        })
        
        self.checkForAlreadyFriends()
        self.checkForPendingRequests()
        
    }
    
    func checkForAlreadyFriends() {
        let query: IBMQuery = IBMQuery(forClass: "Friendship")
        query.whereKey("firstUserEmail", equalTo: CurrentUser.sharedInstance.currentUser?.email)
        query.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if let results = task.result() as? [Friendship] {
                for result in results {
                    self.addedUsers?.append(result.secondUser)
                }
            }
            return nil;
        })
        
        let secondQuery: IBMQuery = IBMQuery(forClass: "Friendship")
        secondQuery.whereKey("secondUserEmail", equalTo: CurrentUser.sharedInstance.currentUser?.email)
        secondQuery.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if let results = task.result() as? [Friendship] {
                for result in results {
                    self.addedUsers?.append(result.firstUser)
                    for user in (self.addedUsers)! {
                        if ((self.userData?.contains(user)) != false) {
                            self.userData?.removeAtIndex((self.addedUsers?.indexOf(user))!)
                        }
                    }
                }
            }
            self.tableView.reloadData()
            return nil;
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
