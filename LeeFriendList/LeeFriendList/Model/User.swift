//
//  User.swift
//  LeeFriendList
//
//  Created by Lee McCormick on 3/16/21.
//

import Foundation
import Firebase

struct UserConstants {
    static let firstNameKey = "firstName"
    static let lastNameKey = "lastName"
    static let emailKey = "email"
    static let blockedUsersKey = "blockedUsers"
    static let blockedUsersByCurrentUserKey = "blockedUsersByCurrentUser"
    static let friendsKey = "friends"
    static let friendsRequestSentKey = "friendsRequestSent"
    static let friendRequestReceivedKey = "friendRequestReceived"
    static let authIDKey = "authID"
    static let uuidKey = "uuid"
}//End of struct

//MARK: - Class
class User {
    
    var firstName: String
    var lastName: String
    var email: String
    var blockedUsers: [String]
    var blockedUsersByCurrentUser: [String]
    var friends: [String]
    var friendsRequestSent: [String]
    var friendRequestReceived: [String]
    var authID: String
    var uuid: String
    
    internal init(firstName: String, lastName: String, email: String, blockedUsers: [String] = [], blockedUsersByCurrentUser: [String] = [], friends: [String] = [], friendsRequestSent: [String] = [], friendRequestReceived: [String] = [], authID: String = "", uuid: String = UUID().uuidString) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.blockedUsers = blockedUsers
        self.blockedUsersByCurrentUser = blockedUsersByCurrentUser
        self.friends = friends
        self.friendsRequestSent = friendsRequestSent
        self.friendRequestReceived = friendRequestReceived
        self.authID = authID
        self.uuid = uuid
    }
    
    convenience init?(document: DocumentSnapshot) {
        
        guard let firstName = document[UserConstants.firstNameKey] as? String,
              let lastName = document[UserConstants.lastNameKey] as? String,
              let email = document[UserConstants.emailKey] as? String,
              let blockedUsers = document[UserConstants.blockedUsersKey] as? [String],
              let blockedUsersByCurrentUser = document[UserConstants.blockedUsersByCurrentUserKey] as? [String],
              let friends = document[UserConstants.friendsKey] as? [String],
              let friendsRequestSent = document[UserConstants.friendsRequestSentKey] as? [String],
              let friendRequestReceived = document[UserConstants.friendRequestReceivedKey] as? [String],
              let authID = document[UserConstants.authIDKey] as? String,
              let uuid = document[UserConstants.uuidKey] as? String else {return nil}
        
        self.init(firstName: firstName, lastName: lastName, email: email, blockedUsers: blockedUsers, blockedUsersByCurrentUser: blockedUsersByCurrentUser, friends: friends, friendsRequestSent: friendsRequestSent, friendRequestReceived: friendRequestReceived, authID: authID, uuid: uuid)
    }
}//End of class

//MARK: - Extensions
extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return rhs.uuid == lhs.uuid
    }
}//End of extension
