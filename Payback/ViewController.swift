//
//  ViewController.swift
//  Payback
//
//  Created by Anya McGee on 2015-11-11.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var transactionsButton: UIButton!
    @IBOutlet weak var groupsButton: UIButton!
    @IBOutlet weak var friendsButton: UIButton!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var glassyLabel: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var score: UILabel!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        transactionsButton.layer.cornerRadius = 10
        groupsButton.layer.cornerRadius = 10
        friendsButton.layer.cornerRadius = 10
        payButton.layer.cornerRadius = 10
        glassyLabel.layer.cornerRadius = 10
        
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.center = self.view.center
        self.view.bringSubviewToFront(self.activityIndicator)
        self.activityIndicator.color = UIColor.blackColor()

        
        // Set user variables
        username.text = CurrentUser.sharedInstance.currentUser?.name
        let s: Float = (CurrentUser.sharedInstance.currentUser?.score)!
        score.text = "\(s)"
        if (s > 0.0) {
            score.textColor = Style.mossGreen
        }
        if (s < 0.0) {
            score.textColor = Style.red
        }
        // load user info
    }
    
    override func viewDidAppear(animated: Bool) {
        self.activityIndicator.startAnimating()
        CurrentUser.sharedInstance.fetchUserScore({(score: Float) in
            self.score.text = "\(score)"
            if (score > 0.0) {
                self.score.textColor = Style.mossGreen
            }
            if (score < 0.0) {
                self.score.textColor = Style.red
            }
            self.activityIndicator.stopAnimating()
        })
    }


}

