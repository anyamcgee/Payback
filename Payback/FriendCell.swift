//
//  FriendCell.swift
//  Payback
//
//  Created by Alice Fredine on 2015-12-13.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class FriendCell : UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    
    var friend: User? {
        didSet {
            updateLabels()
        }
    }
    
    var friendship: Friendship? {
        didSet {
            updateLabels()
        }
    }
    
    func updateLabels() {
        
        if let user = self.friend {
            let userGroup = dispatch_group_create()
            dispatch_group_enter(userGroup)
            user.fetchIfNecessary().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
                dispatch_group_leave(userGroup)
                return nil;
                })
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
                dispatch_group_wait(userGroup, DISPATCH_TIME_FOREVER)
                dispatch_async(dispatch_get_main_queue(), {
                    self.nameLabel.text = user.name
                    if let friendship = self.friendship {
                        var s: Float = 0.0
                        if (friendship.firstUserEmail == user.email) {
                            s = friendship.secondUserScore
                            if (s >= 0) {
                                self.scoreLabel.textColor = Style.mediumGreen
                                self.scoreLabel.text = "Owes you: \(s)"
                            }
                            else {
                                self.scoreLabel.textColor = Style.red
                                self.scoreLabel.text = "You owe: \(s)"
                            }
                        }
                        else {
                            s = friendship.firstUserScore
                            if (s >= 0) {
                                self.scoreLabel.textColor = Style.mediumGreen
                                self.scoreLabel.text = "Owes you: \(s)"
                            }
                            else {
                                self.scoreLabel.textColor = Style.red
                                self.scoreLabel.text = "You owe: \(s)"
                            }
                        }
                    }
                })
            })
        }
    }

}
