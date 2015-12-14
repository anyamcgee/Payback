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
    
    func setUpActivityIndicator() {
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.center = self.view.center
        self.view.bringSubviewToFront(self.activityIndicator)
        self.activityIndicator.color = UIColor.grayColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchBar.delegate = self
        
        setUpActivityIndicator()
        
        self.activityIndicator.startAnimating()
        CurrentUser.sharedInstance.getUserGroups({(result: [Group]?) in
            self.activityIndicator.stopAnimating()
            if result != nil {
                self.groups = result!
                self.displayGroup = result!

            }
            self.tableView.reloadData()
        })
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
                    destVC.group = self.displayGroup[indexPath.row]
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
