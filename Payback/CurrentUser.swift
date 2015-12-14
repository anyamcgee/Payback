//
//  CurrentUser.swift
//  Payback
//
//  Created by Alice Fredine on 2015-12-12.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

// Typical Singleton Pattern to Store Current User Info

import UIKit

class CurrentUser {
    
    static var sharedInstance = CurrentUser();
    
    private var user: User?;
    private var userGroups: [Group]?
    private var userFriendships: [Friendship]?
    private var userFriends: [User]?
    private var transactions: [Transaction]?
    private var groupTransactions: [Group : [GroupTransaction]]
    private var userGroupInfo: [Group : [UserGroupInfo]]
    
    private var foundAllUsers: dispatch_group_t
    private var foundAllTransactions: dispatch_group_t
    
    internal var currentUser: User? {
        get {
            return self.user;
        }
        set (value) {
            self.user = value;
        }
    }
    
    private init() {
        self.foundAllUsers = dispatch_group_create()
        self.foundAllTransactions = dispatch_group_create()
        self.groupTransactions = [Group : [GroupTransaction]]()
        self.userGroupInfo = [Group : [UserGroupInfo]]()
    }
    
    // MARK- Get groups
    
    func getUserGroups(callback: ((result: [Group]?) -> Void)) {
        if self.userGroups != nil {
            callback(result: self.userGroups)
        } else {
            self.userGroups = [Group]()
            let query: IBMQuery = IBMQuery(forClass: "UserGroupInfo")
            query.whereKey("user", equalTo: CurrentUser.sharedInstance.currentUser)
            let fetchedAll = dispatch_group_create()
            query.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
                if let results = task.result() as? [UserGroupInfo] {
                    for result in results {
                        dispatch_group_enter(fetchedAll)
                        result.group.fetchIfNecessary().continueWithBlock({(task: BFTask!) -> BFTask! in
                            if let result = task.result() as? Group {
                               self.userGroups!.append(result)
                            }
                            dispatch_group_leave(fetchedAll)
                            return nil
                        })
                    }
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
                        dispatch_group_wait(fetchedAll, DISPATCH_TIME_FOREVER)
                        dispatch_async(dispatch_get_main_queue(), {
                            callback(result: self.userGroups)
                        })
                    })
                    return nil
                } else {
                    print("Could not fetch UserGroupInfo")
                    return nil
                }
            })
        }
    }
    
    // MARK- Find friends/friendships
    
    func getUserFriends(callback: ((result: [User]?) -> Void)) {
        if self.userFriends != nil {
            callback(result: self.userFriends)
        } else {
            findFirstUsers()
            findSecondUsers()
            self.userFriends = [User]()
            self.userFriendships = [Friendship]()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                dispatch_group_wait(self.foundAllUsers, DISPATCH_TIME_FOREVER)
                dispatch_async(dispatch_get_main_queue(), {
                    callback(result: self.userFriends)
                })
            })
        }
    }
    
    func getUserFriendships(callback: ((result: [Friendship]?) -> Void)) {
        if self.userFriendships != nil {
            callback(result: self.userFriendships)
        } else {
            findFirstUsers()
            findSecondUsers()
            self.userFriends = [User]()
            self.userFriendships = [Friendship]()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                dispatch_group_wait(self.foundAllUsers, DISPATCH_TIME_FOREVER)
                dispatch_async(dispatch_get_main_queue(), {
                    callback(result: self.userFriendships)
                })
            })
        }
    }
    
    func getFriendsData(callback: ((friends: [User]?, friendships: [Friendship]?) -> Void)) {
        if self.userFriends != nil && self.userFriendships != nil {
            callback(friends: self.userFriends, friendships: self.userFriendships)
        } else {
            findFirstUsers()
            findSecondUsers()
            self.userFriends = [User]()
            self.userFriendships = [Friendship]()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                dispatch_group_wait(self.foundAllUsers, DISPATCH_TIME_FOREVER)
                dispatch_async(dispatch_get_main_queue(), {
                    callback(friends: self.userFriends, friendships: self.userFriendships)
                })
            })
        }
    }
    
    // MARK- Helper functions for find friends
    
    func findFirstUsers() {
        dispatch_group_enter(foundAllUsers)
        let query: IBMQuery = IBMQuery(forClass: "Friendship")
        query.whereKey("firstUser", equalTo: CurrentUser.sharedInstance.currentUser)
        query.find().continueWithBlock({(task: BFTask!) -> BFTask! in
            if let results = task.result() as? [Friendship] {
                for result in results {
                    self.userFriendships?.append(result)
                    self.userFriends?.append(result.secondUser)
                    dispatch_group_enter(self.foundAllUsers)
                    result.secondUser.fetchIfNecessary().continueWithBlock({(task: BFTask!) -> BFTask! in
                        dispatch_group_leave(self.foundAllUsers)
                        return nil
                    })
                }
            }
            dispatch_group_leave(self.foundAllUsers)
            return nil
        })
    }
    
    func findSecondUsers() {
        dispatch_group_enter(foundAllUsers)
        let query: IBMQuery = IBMQuery(forClass: "Friendship")
        query.whereKey("secondUser", equalTo: CurrentUser.sharedInstance.currentUser)
        query.find().continueWithBlock({(task: BFTask!) -> BFTask! in
            if let results = task.result() as? [Friendship] {
                for result in results {
                    self.userFriendships?.append(result)
                    self.userFriends?.append(result.firstUser)
                    dispatch_group_enter(self.foundAllUsers)
                    result.firstUser.fetchIfNecessary().continueWithBlock({(task: BFTask!) -> BFTask! in
                        dispatch_group_leave(self.foundAllUsers)
                        return nil
                    })
                }
            }
            dispatch_group_leave(self.foundAllUsers)
            return nil
        })
    }
    
    // MARK:- Get user transactions
    
    func getTransactions(callback: ((result: [Transaction]?) -> Void)) {
        if self.user == nil { return }
        
        if self.transactions != nil {
            callback(result: self.transactions)
        } else {
            self.transactions = [Transaction]()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                dispatch_group_wait(self.foundAllTransactions, DISPATCH_TIME_FOREVER)
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.transactions?.sortInPlace({(first: Transaction, second: Transaction) -> Bool in
                        if (first.createdAt.timeIntervalSince1970 > second.createdAt.timeIntervalSince1970) {
                            return true
                        }
                        else {
                            return false
                        }
                    })
                    callback(result: self.transactions)
                })
            })
        }
    }
    
    // MARK:- Helper functions for getting transactions
    
    func getTo() {
        dispatch_group_enter(self.foundAllTransactions)
        let newQuery: IBMQuery = IBMQuery(forClass: "Transaction")
        let user = self.currentUser!
        newQuery.whereKey("toUserEmail", equalTo: user.email)
        newQuery.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if let result = task.result() as? [Transaction] {
                self.transactions?.appendContentsOf(result)
            }
            dispatch_group_leave(self.foundAllTransactions)
            return nil
        })
    }
    
    func getFrom() {
        dispatch_group_enter(self.foundAllTransactions)
        let fromQuery: IBMQuery = IBMQuery(forClass: "Transaction")
        fromQuery.whereKey("fromUserEmail", equalTo: self.currentUser!.email)
        fromQuery.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
            if let result = task.result() as? [Transaction] {
                self.transactions?.appendContentsOf(result)
            }
            dispatch_group_leave(self.foundAllTransactions)
            return nil
        })
    }
    
    func getTransactions(forGroup group: Group, callback: ((result: [GroupTransaction]) -> Void)) {
        if let transactions = self.groupTransactions[group] {
            callback(result: transactions)
        } else {
            let query = IBMQuery(forClass: "GroupTransaction")
            query.whereKey("group", equalTo: group)
            query.find().continueWithBlock({(task: BFTask!) -> BFTask! in
                if let results = task.result() as? [Payback.GroupTransaction] {
                    self.groupTransactions[group] = results
                    callback(result: results)
                }
                return nil
            })
        }
    }
    
    func getUserInfo(forGroup group: Group, callback: ((result: [UserGroupInfo]) -> Void)) {
        if let userInfo = self.userGroupInfo[group] {
            callback(result: userInfo)
        } else {
            let query: IBMQuery = IBMQuery(forClass: "UserGroupInfo")
            query.whereKey("group", equalTo: group)
            query.find().continueWithSuccessBlock({(task: BFTask!) -> BFTask! in
                if let result = task.result() as? [UserGroupInfo] {
                    self.userGroupInfo[group] = result
                    callback(result: result)
                }
                return nil
            })
        }
    }
    
}