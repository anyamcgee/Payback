//
//  TransactionsViewController.swift
//  Payback
//
//  Created by Alice Fredine on 2015-12-12.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class TransactionsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var transactions: [Transaction] = [Transaction]()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        CurrentUser.sharedInstance.getTransactions({(result: [Transaction]?) in
            if result != nil {
                self.transactions = result!
            }
            self.tableView.reloadData()
        })
        
        /**
        let newQuery: IBMQuery = IBMQuery(forClass: "Transaction")
        let user = CurrentUser.sharedInstance.currentUser!
        newQuery.whereKey("toUserEmail", equalTo: user.email)
        newQuery.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if let result = task.result() as? [Transaction] {
                self.transactions = result
            }
            return nil
        })
        let fromQuery: IBMQuery = IBMQuery(forClass: "Transaction")
        fromQuery.whereKey("fromUserEmail", equalTo: user.email)
        fromQuery.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if let result = task.result() as? [Transaction] {
                self.transactions.appendContentsOf(result)
            }
            self.transactions.sortInPlace({(first: Transaction, second: Transaction) -> Bool in
                if (first.createdAt.timeIntervalSince1970 > second.createdAt.timeIntervalSince1970) {
                    return true
                }
                else {
                    return false
                }
            })
            self.tableView.reloadData()
            return nil
        })**/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpActivityIndicator() {
        self.activityIndicator.center = self.view.center
        self.view.addSubview(self.activityIndicator)
        self.view.bringSubviewToFront(self.activityIndicator)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row >= 0 && indexPath.row < self.transactions.count {
            
            if let cell = tableView.dequeueReusableCellWithIdentifier("transactionCell") as? TransactionCell {
                cell.transaction = self.transactions[indexPath.row]
                return cell
                
            } else {
                let cell = TransactionCell()
                cell.transaction = self.transactions[indexPath.row]
                
                return cell
            }
        } else {
            return GroupCell()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transactions.count
    }


    
}

