//
//  FriendRequestsViewController.swift
//  Payback
//
//  Created by Alice Fredine on 2015-12-13.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class FriendRequestsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var requestData: [FriendRequest]?
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.r
        
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.center = self.view.center
        self.view.bringSubviewToFront(self.activityIndicator)
        self.activityIndicator.color = UIColor.grayColor()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.checkForRequests()
        
    }
    
    func checkForRequests() {
        
        self.activityIndicator.startAnimating()
        let query: IBMQuery = IBMQuery(forClass: "FriendRequest")
        query.whereKey("toEmail", equalTo: CurrentUser.sharedInstance.currentUser!.email)
        query.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if let result = task.result() as? [FriendRequest] {
                self.requestData = result
            }
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            return nil;
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.requestData?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.requestData != nil && indexPath.row < self.requestData!.count {
            if let cell = self.tableView.dequeueReusableCellWithIdentifier("friendRequestCell") as? FriendRequestCell {
                cell.request = self.requestData?[indexPath.row]
                return cell
            }
        }
        return UITableViewCell()
    }

    

}
