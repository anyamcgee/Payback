//
//  MyGroupsViewController.swift
//  Payback
//
//  Created by Anya McGee on 2015-11-25.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import Foundation
import UIKit

class MyGroupsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var groups: [Group] = [Group]()
    @IBOutlet weak var tableView: UITableView!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
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
        
        setUpActivityIndicator()
        
        self.activityIndicator.startAnimating()
        CurrentUser.sharedInstance.getUserGroups({(result: [Group]?) in
            self.activityIndicator.stopAnimating()
            if result != nil {
                self.groups = result!
            }
            self.tableView.reloadData()
        })
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row >= 0 && indexPath.row < self.groups.count {
            
            if let cell = tableView.dequeueReusableCellWithIdentifier("groupCell") as? GroupCell {
                cell.group = self.groups[indexPath.row]
                return cell
                
            } else {
                let cell = GroupCell()
                cell.group = self.groups[indexPath.row]
                
                return cell
            }
        } else {
            return GroupCell()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groups.count
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
    
}
