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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        transactionsButton.layer.cornerRadius = 10
        groupsButton.layer.cornerRadius = 10
        friendsButton.layer.cornerRadius = 10
        payButton.layer.cornerRadius = 10
        glassyLabel.layer.cornerRadius = 10
        
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
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

