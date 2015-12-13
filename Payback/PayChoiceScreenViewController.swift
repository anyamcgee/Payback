//
//  PayChoiceScreenViewController.swift
//  Payback
//
//  Created by Alice Fredine on 2015-12-12.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class PayChoiceScreenViewController : UIViewController {

    @IBOutlet weak var payUserButton: UIButton!
    @IBOutlet weak var payGroupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.r 
        payUserButton.layer.cornerRadius = 10
        payGroupButton.layer.cornerRadius = 10
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
