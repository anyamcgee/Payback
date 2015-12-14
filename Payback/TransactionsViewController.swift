//
//  TransactionsViewController.swift
//  Payback
//
//  Created by Alice Fredine on 2015-12-12.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class TransactionsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var transactions: [Transaction] = [Transaction]()
    var displayData: [Transaction] = [Transaction]()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchBar.delegate = self
        
        CurrentUser.sharedInstance.getTransactions({(result: [Transaction]?) in
            if result != nil {
                self.transactions = result!
                self.displayData = result!
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
            self.displayData = self.transactions
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
        if indexPath.row >= 0 && indexPath.row < self.displayData.count {
            
            if let cell = tableView.dequeueReusableCellWithIdentifier("transactionCell") as? TransactionCell {
                cell.transaction = self.displayData[indexPath.row]
                return cell
                
            } else {
                let cell = TransactionCell()
                
                cell.transaction = self.displayData[indexPath.row]
                
                return cell
            }
        } else {
            return GroupCell()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayData.count
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            filterFriends(searchText)
        } else {
            displayData = transactions
        }
        self.tableView.reloadData()
    }
    
    func filterFriends(searchText: String) {
        displayData = transactions.filter{
            let transaction = ($0 as Transaction)
            if (transaction.to.email == CurrentUser.sharedInstance.currentUser!.email) {
            //print("payment from: ", transaction.from.name)
                return
                    (transaction.fromUserName.lowercaseString.containsString(searchText.lowercaseString) ||
                    (transaction.reason != nil &&
                        transaction.reason!.lowercaseString.containsString(searchText.lowercaseString)))
            } else {
                return
                    (transaction.toUserName.lowercaseString.containsString(searchText.lowercaseString) ||
                    (transaction.reason != nil &&
                        transaction.reason!.lowercaseString.containsString(searchText.lowercaseString)))
            }
        }
    }
    
}

