//
//  SelectGroupViewController.swift
//  Payback
//
//  Created by Anya McGee on 2015-12-13.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class SelectGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var groups: [Group] = [Group]()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var tableView: UITableView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.navigationItem.title = "Select a Group"
        
        setUpActivityIndicator()
        
        CurrentUser.sharedInstance.getUserGroups({(result: [Group]?) in
            if result != nil {
                self.groups = result!
            }
            self.tableView.reloadData()
        })
    }
    
    func setUpActivityIndicator() {
        self.activityIndicator.center = self.view.center
        self.view.addSubview(self.activityIndicator)
        self.view.bringSubviewToFront(self.activityIndicator)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row >= 0 && indexPath.row < self.groups.count {
            
            if let cell = tableView.dequeueReusableCellWithIdentifier("groupCell") as? GroupCell {
                cell.group = self.groups[indexPath.row]
                return cell
                
            } else {
                let cell = GroupCell()
                
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
        self.performSegueWithIdentifier("showAddTransaction", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAddTransaction" {
            if let destVC = segue.destinationViewController as? AddGroupTransactionViewController {
                if let indexPath  = sender as? NSIndexPath {
                    destVC.group = self.groups[indexPath.row]
                }
            }
        }
    }

}
