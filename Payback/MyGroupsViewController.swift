//
//  MyGroupsViewController.swift
//  Payback
//
//  Created by Anya McGee on 2015-11-25.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import Foundation
import UIKit

class MyGroupsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var groups: [Group] = [Group]()
    var displayGroup: [Group] = [Group]()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchBar.delegate = self
        
        setUpActivityIndicator()
        
        let query: IBMQuery = IBMQuery(forClass: "UserGroupInfo")
        print(CurrentUser.sharedInstance.currentUser!.name)
        query.whereKey("user", equalTo: CurrentUser.sharedInstance.currentUser)
        let fetchedAll = dispatch_group_create()
        query.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if let results = task.result() as? [UserGroupInfo] {
                for result in results {
                    dispatch_group_enter(fetchedAll)
                    result.group.fetchIfNecessary().continueWithBlock({(task: BFTask!) -> BFTask! in
                        if let result = task.result() as? Group {
                            self.groups.append(result)
                            self.displayGroup.append(result)
                        }
                        dispatch_group_leave(fetchedAll)
                        return nil
                    })
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
                    dispatch_group_wait(fetchedAll, DISPATCH_TIME_FOREVER)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                })
                return nil
            } else {
                print("Could not fetch UserGroupInfo")
                return nil
            }
        })
    }
    
    func setUpActivityIndicator() {
        self.activityIndicator.center = self.view.center
        self.view.addSubview(self.activityIndicator)
        self.view.bringSubviewToFront(self.activityIndicator)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row >= 0 && indexPath.row < self.displayGroup.count {
            
            if let cell = tableView.dequeueReusableCellWithIdentifier("groupCell") as? GroupCell {
                cell.group = self.displayGroup[indexPath.row]
                return cell
                
            } else {
                let cell = GroupCell()
                cell.group = self.displayGroup[indexPath.row]
                
                return cell
            }
        } else {
            return GroupCell()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayGroup.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showGroupDetail", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showGroupDetail" {
            if let destVC = segue.destinationViewController as? GroupDetailViewController {
                if let indexPath  = sender as? NSIndexPath {
                    destVC.group = self.groups[indexPath.row]
                }
            }
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            filterGroups(searchText)
        } else {
            displayGroup = groups
        }
        self.tableView.reloadData()
    }
    
    
    func filterGroups(searchText: String) {
        displayGroup = groups.filter{
            group in (group.name.lowercaseString.containsString(searchText.lowercaseString))
        }
    }
    
    
}
