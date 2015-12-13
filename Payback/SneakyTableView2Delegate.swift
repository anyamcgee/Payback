//
//  SneakyTableView2Delegate.swift
//  Payback
//
//  Created by Anya McGee on 2015-12-13.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class SneakyTableView2Delegate: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var data: [GroupTransaction] = [GroupTransaction]()
    var group: Group
    var tableView: UITableView
    
    init(tableView: UITableView, group: Group) {
        self.tableView = tableView
        self.group = group
        self.data = [GroupTransaction]()
        
        super.init()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getData()
    }
    
    func getData() {
        let query = IBMQuery(forClass: "GroupTransaction")
        query.whereKey("group", equalTo: self.group)
        query.find().continueWithBlock({(task: BFTask!) -> BFTask! in
            if let results = task.result() as? [Payback.GroupTransaction] {
                self.data = results
                self.tableView.reloadData()
            }
            return nil
        })
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row >= 0 && indexPath.row < self.data.count {
            if let cell = self.tableView.dequeueReusableCellWithIdentifier("transactionCell") as? GroupTransactionTableViewCell {
                cell.amountLabel.text = "\(self.data[indexPath.row].amount)"
                cell.userLabel.text = self.data[indexPath.row].user.name
                cell.dateLabel.text = self.data[indexPath.row].createdAt.description
                cell.reasonLabel.text = self.data[indexPath.row].reason
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
}
