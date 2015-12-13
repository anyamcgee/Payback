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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        let query: IBMQuery = IBMQuery(forClass: "User")
        query.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            let result = task.result() as? [User]
            self.userData = result
            self.tableView.reloadData()
            return nil
        })

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
    
}
