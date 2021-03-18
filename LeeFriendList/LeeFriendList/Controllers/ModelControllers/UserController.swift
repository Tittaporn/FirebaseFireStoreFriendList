//
//  UserController.swift
//  LeeFriendList
//
//  Created by Lee McCormick on 3/16/21.
//

import FirebaseFirestore
import Foundation
import Firebase
import FirebaseAuth

class UserController {
    
    //MARK: - Properties
    static var shared = UserController()
    var users: [User] = []
    var currentUser: User?
    let db = Firestore.firestore()
    let userCollection = "users"
    
    func signupNewUserAndCreateNewContactWith(firstName: String, lastName: String, email: String, password: String, completion: @escaping (Result<User, NetworkError>) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Error Creating New User !\(error.localizedDescription)")
            }
            
            guard let authResult = result else {return completion(.failure(.noData))}
            let newUser = User(firstName: firstName, lastName: lastName, email: email)
            let userRef = self.db.collection(self.userCollection)
            userRef.document(newUser.uuid).setData([
                UserConstants.firstNameKey : newUser.firstName,
                UserConstants.lastNameKey : newUser.lastName,
                UserConstants.emailKey : newUser.email,
                UserConstants.blockedUsersKey : newUser.blockedUsers,
                UserConstants.blockedUsersByCurrentUserKey : newUser.blockedUsersByCurrentUser,
                UserConstants.friendsKey : newUser.friends,
                UserConstants.friendsRequestSentKey : newUser.friendsRequestSent,
                UserConstants.friendRequestReceivedKey : newUser.friendRequestReceived,
                UserConstants.authIDKey : authResult.user.uid,
                UserConstants.uuidKey : newUser.uuid
            ]) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return completion(.failure(.thrownError(error)))
                } else {
                    return completion(.success(newUser))
                }
            }
        }
    }
    
    func loginWith(email: String, password: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("================ERROR, LOGGIN USER =============")
                print("=========================================================")
                completion(.failure(.thrownError(error)))
            }
            guard let authDataResult = result else {return completion(.failure(.unableToDecode))}
            guard let email = authDataResult.user.email else {return completion(.failure(.noData))}
            completion(.success(email))
        }
    }
    
    //MARK: - Methods
    func fetchAllUsers(completion: @escaping(Result<[User], NetworkError>) -> Void) {
        let currentUserID = Auth.auth().currentUser?.uid
        guard let upwrapCurrentUserID = currentUserID else { return completion(.failure(.unableToDecode)) }
        db.collectionGroup(userCollection).whereField(UserConstants.authIDKey, isNotEqualTo: upwrapCurrentUserID).getDocuments { (users, error) in
            if let error = error {
                print("Error in FETCH ALL USER!\(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.thrownError(error)))
            }
            guard let users = users else {return completion(.failure(.noData))}
            var userArray: [User] = []
            for document in users.documents {
                guard let user = User(document: document) else {return completion(.failure(.unableToDecode))}
                //if
                userArray.append(user)
                print("SUCCESSFULLY! FETCH ALL USERS! \(#function)")
            }
            return completion(.success(userArray))
        }
    }
    
    
   
    
    func fetchCurrentUser(completion: @escaping(Result<User, NetworkError>) -> Void) {
        let currentUserID = Auth.auth().currentUser?.uid
        guard let upwrapCurrentUserID = currentUserID else { return completion(.failure(.unableToDecode)) }
        db.collectionGroup(userCollection).whereField(UserConstants.authIDKey, isEqualTo: upwrapCurrentUserID).getDocuments { (users, error) in
            if let error = error {
                print("Error in FETCH ALL USER!\(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.thrownError(error)))
            }
            guard let users = users else {return completion(.failure(.noData))}
            for document in users.documents {
                guard let user = User(document: document) else {return completion(.failure(.unableToDecode))}
                self.currentUser = user
                print("SUCCESSFULLY! FETCH CURRENT USERS!")
                return completion(.success(user))
            }
        }
    }
    
    func sendFriendRequest(to user: User, completion: @escaping (Result<User, NetworkError>) -> Void) {
        guard let upwrapCurrentUser = self.currentUser else {return}
        if !upwrapCurrentUser.friends.contains(user.uuid) && !upwrapCurrentUser.friendsRequestSent.contains(user.uuid) &&  !upwrapCurrentUser.blockedUsers.contains(user.uuid) {
            
            db.collection(userCollection).document(user.uuid).updateData([UserConstants.friendRequestReceivedKey : FieldValue.arrayUnion([upwrapCurrentUser.uuid])]) { (error) in
                if let error = error {
                    return completion(.failure(.thrownError(error)))
                } else {
                    return completion(.success(user))
                }
            }
            
            db.collection(userCollection).document(upwrapCurrentUser.uuid).updateData([UserConstants.friendsRequestSentKey : FieldValue.arrayUnion([user.uuid])]) { (error) in
                if let error = error {
                    return completion(.failure(.thrownError(error)))
                } else {
                    return completion(.success(user))
                }
            }
        } else {
            return completion(.failure(.repeatRequest))
        }
    }
    
    func fetchPendingFriendRequestsSentBy(currentUser: User, completion: @escaping (Result<[User], NetworkError>) -> Void) {
        
        db.collection(userCollection).document(currentUser.uuid).getDocument { (querySnapshot, error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            } else {
                guard let querySnapshot = querySnapshot,
                      let userData = User(document: querySnapshot) else {return completion(.failure(.noData))}
                
                var pendingFriendRequestArray: [User] = []
                
                for id in userData.friendsRequestSent {
                    self.db.collection(self.userCollection).document(id).getDocument { (snapshot, error) in
                        if let error = error {
                            return completion(.failure(.thrownError(error)))
                        } else {
                            guard let snapshot = snapshot,
                                  let potentialFriend = User(document: snapshot) else {return completion(.failure(.unableToDecode))}
                            pendingFriendRequestArray.append(potentialFriend)
                            return completion(.success(pendingFriendRequestArray))
                        }
                    }
                }
            }
        }
    }
    
    func cancelFriendRequest(to user: User, completion: @escaping (Result<User, NetworkError>) -> Void) {
        guard let upwrapCurrentUser = self.currentUser else {return}
        db.collection(userCollection).document(user.uuid).updateData([UserConstants.friendRequestReceivedKey : FieldValue.arrayRemove([upwrapCurrentUser.uuid])]) { (error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            } else {
                return completion(.success(user))
            }
        }
        
        db.collection(userCollection).document(upwrapCurrentUser.uuid).updateData([UserConstants.friendsRequestSentKey : FieldValue.arrayRemove([user.uuid])]) { (error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            } else {
                return completion(.success(user))
            }
        }
    }
    
    func fetchFriendRequestsReceived(currentUser: User, completion: @escaping (Result<[User], NetworkError>) -> Void) {
        
        db.collection(userCollection).document(currentUser.uuid).getDocument { (querySnapshot, error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            } else {
                guard let querySnapshot = querySnapshot,
                      let userData = User(document: querySnapshot) else {return completion(.failure(.noData))}
                
                var friendRequestReceievedArray: [User] = []
                
                for id in userData.friendRequestReceived {
                    self.db.collection(self.userCollection).document(id).getDocument { (snapshot, error) in
                        if let error = error {
                            return completion(.failure(.thrownError(error)))
                        } else {
                            guard let snapshot = snapshot,
                                  let fetchFriendRequestReceived = User(document: snapshot) else {return completion(.failure(.unableToDecode))}
                            friendRequestReceievedArray.append(fetchFriendRequestReceived)
                            return completion(.success(friendRequestReceievedArray))
                        }
                    }
                }
            }
        }
    }
    
    func acceptFriendRequest(user: User, completion: @escaping (Result<User, NetworkError>) -> Void) {
        
        guard let currentUser = currentUser else {return}
        
        db.collection(userCollection).document(currentUser.uuid).updateData([UserConstants.friendsKey : FieldValue.arrayUnion([user.uuid])]) { (error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            } else {
                print("FINALLY! \(currentUser.firstName)  ACCEPT \(user.firstName) FRIEND'S REQUEST.")
            }
        }
        
        db.collection(userCollection).document(currentUser.uuid).updateData([UserConstants.friendRequestReceivedKey : FieldValue.arrayRemove([user.uuid])]) { (error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            } else {
                print("SO! \(user.firstName) IS REMOVE FROM \(currentUser.firstName) FRIEND'S REQUEST RECEIVED' LIST.")
            }
        }
        
        db.collection(userCollection).document(user.uuid).updateData([UserConstants.friendsKey : FieldValue.arrayUnion([currentUser.uuid])]) { (error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            } else {
                print("FINALLY! \(user.firstName) GOT ACCEPTED FROM \(currentUser.firstName) TO BE FRIEND.")
            }
        }
        
        db.collection(userCollection).document(user.uuid).updateData([UserConstants.friendsRequestSentKey : FieldValue.arrayRemove([currentUser.uuid])]) { (error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            } else {
                print("SO!\(currentUser.firstName) IS REMOVE FROM \(user.firstName)  FRIEND'S REQUEST LIST.")
            }
        }
        completion(.success(user))
    }
    
    func fetchFriendsFor(currentUser: User, completion: @escaping (Result<[User], NetworkError>) -> Void) {
        db.collection(userCollection).document(currentUser.uuid).getDocument { (querySnapshot, error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            } else {
                guard let querySnapshot = querySnapshot,
                      let userData = User(document: querySnapshot) else {return completion(.failure(.noData))}
                var friendsArray: [User] = []
                for id in userData.friends {
                    self.db.collection(self.userCollection).document(id).getDocument { (snapshot, error) in
                        if let error = error {
                            return completion(.failure(.thrownError(error)))
                        } else {
                            guard let snapshot = snapshot,
                                  let fetchFriend = User(document: snapshot) else {return completion(.failure(.unableToDecode))}
                            friendsArray.append(fetchFriend)
                            return completion(.success(friendsArray))
                        }
                    }
                }
            }
        }
    }
    
    func blockUser(_ user: User, completion: @escaping (Result<User, NetworkError>) -> Void) {
        guard let currentUser = currentUser else {return}
        db.collection(userCollection).document(currentUser.uuid).updateData([UserConstants.friendsKey : FieldValue.arrayRemove([user.uuid])]) { (error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            } else {
                print("FINALLY! \(currentUser.firstName) UNFRIENDED AND GOING TO BLOCK \(user.firstName) ")
            }
        }
        
        db.collection(userCollection).document(currentUser.uuid).updateData([UserConstants.blockedUsersKey : FieldValue.arrayUnion([user.uuid])]) { (error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            } else {
                print("FINALLY! \(currentUser.firstName) BLOCKED \(user.firstName).")
            }
        }
        
        db.collection(userCollection).document(currentUser.uuid).updateData([UserConstants.blockedUsersByCurrentUserKey : FieldValue.arrayUnion([user.uuid])]) { (error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            } else {
                print("FINALLY! \(currentUser.firstName) BLOCKED \(user.firstName).")
            }
        }
        
        db.collection(userCollection).document(user.uuid).updateData([UserConstants.friendsKey : FieldValue.arrayRemove([currentUser.uuid])]) { (error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            } else {
                print("FINALLY! \(user.firstName) ALSO GET BLOCKED AND UNFRIENDED \(currentUser.firstName).")
            }
        }
        
        db.collection(userCollection).document(user.uuid).updateData([UserConstants.blockedUsersKey : FieldValue.arrayUnion([currentUser.uuid])]) { (error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            } else {
                print("FINALLY! \(user.firstName) GOT \(currentUser.firstName) IN BLOCKED LIST.")
            }
        }
        
    }
    

    
    //fetchBlockuser
    func fetchBlockedUsersByCurrentUser(_ currentUser: User, completion: @escaping (Result<[User], NetworkError>) -> Void) {
        db.collection(userCollection).document(currentUser.uuid).getDocument { (querySnapshot, error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            } else {
                guard let querySnapshot = querySnapshot,
                      let userData = User(document: querySnapshot) else {return completion(.failure(.noData))}
                var blockUserArray: [User] = []
                for id in userData.blockedUsersByCurrentUser {
                    self.db.collection(self.userCollection).document(id).getDocument { (snapshot, error) in
                        if let error = error {
                            return completion(.failure(.thrownError(error)))
                        } else {
                            guard let snapshot = snapshot,
                                  let blocksUsers = User(document: snapshot) else {return completion(.failure(.unableToDecode))}
                            blockUserArray.append(blocksUsers)
                            return completion(.success(blockUserArray))
                        }
                    }
                }
            }
        }
    }
    
    func fetchBlockedUsersToFetchAllUser(_ currentUser: User, completion: @escaping (Result<[User], NetworkError>) -> Void) {
        db.collection(userCollection).document(currentUser.uuid).getDocument { (querySnapshot, error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            } else {
                guard let querySnapshot = querySnapshot,
                      let userData = User(document: querySnapshot) else {return completion(.failure(.noData))}
                var blockUserArray: [User] = []
                for id in userData.blockedUsers {
                    self.db.collection(self.userCollection).document(id).getDocument { (snapshot, error) in
                        if let error = error {
                            return completion(.failure(.thrownError(error)))
                        } else {
                            guard let snapshot = snapshot,
                                  let blocksUsers = User(document: snapshot) else {return completion(.failure(.unableToDecode))}
                            blockUserArray.append(blocksUsers)
                            return completion(.success(blockUserArray))
                        }
                    }
                }
            }
        }
    }

    func unfriendUser(_ user: User, completion: @escaping (Result<User, NetworkError>) -> Void) {
        guard let currentUser = currentUser else {return}
        db.collection(userCollection).document(currentUser.uuid).updateData([UserConstants.friendsKey : FieldValue.arrayRemove([user.uuid])]) { (error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            } else {
                print("FINALLY! \(currentUser.firstName)  BLOCKED \(user.firstName).")
            }
        }
            
        db.collection(userCollection).document(user.uuid).updateData([UserConstants.friendsKey : FieldValue.arrayRemove([currentUser.uuid])]) { (error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            } else {
                print("FINALLY! \(user.firstName) GOT \(currentUser.firstName) IN BLOCKED LIST.")
            }
        }
    }
    
    func unblockedUser(_ user: User, completion: @escaping (Result<User, NetworkError>) -> Void) {
        
        guard let currentUser = currentUser else {return}

        db.collection(userCollection).document(currentUser.uuid).updateData([UserConstants.blockedUsersByCurrentUserKey : FieldValue.arrayRemove([user.uuid])]) { (error) in
                    if let error = error {
                        return completion(.failure(.thrownError(error)))
                    } else {
                        print("FINALLY! \(currentUser.firstName)  UNBLOCKED \(user.firstName).")
            }
        }
        
        db.collection(userCollection).document(currentUser.uuid).updateData([UserConstants.blockedUsersKey : FieldValue.arrayRemove([user.uuid])]) { (error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            } else {
                print("FINALLY! \(currentUser.firstName)  UNBLOCKED \(user.firstName).")
            }
        }
            
        db.collection(userCollection).document(user.uuid).updateData([UserConstants.blockedUsersKey : FieldValue.arrayRemove([currentUser.uuid])]) { (error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            } else {
                print("FINALLY! \(user.firstName) GOT OUT FROM \(currentUser.firstName)  BLOCKED LIST.")
            }
        }
    }
}


/* //NEED TO FETCH THE ALL THE USERS THAT ARE NOT CURRENT USER, NOT IN THE `blockedUsers`, NOT IN THE `friends`, NOT IN THE `friendsRequestSent`
 
 func fetchAllUsersWithOutBlockedAndCurrentUser(currentUser: User, completion: @escaping(Result<[User], NetworkError>) -> Void) {
        db.collectionGroup(userCollection).whereField(UserConstants.authIDKey, isNotEqualTo: currentUser.authID).getDocuments { (users, error) in
            if let error = error {
                print("Error in FETCH ALL USER!\(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.thrownError(error)))
            }
            
            guard let users = users else {return completion(.failure(.noData))}
            var userArray: [User] = []
            for document in users.documents {
                guard let user = User(document: document) else {return completion(.failure(.unableToDecode))}
                
                
                var blockedUsers: [User] = []
                self.fetchBlockedUsersByCurrentUser(currentUser) { (results) in
                            switch results {
                            case .success(let users):
                                blockedUsers = users
                            case .failure(let error):
                                completion(.failure(.thrownError(error)))
                            }
                        }
                    for blockedUser in blockedUsers {
                        if user.uuid != blockedUser.uuid {
                            print("--------------------user.uuid  : \(user.uuid) in blockedUser.uuid  \(blockedUser.uuid ) \(#function) : ----------------------------\n)")
                            userArray.append(user)
                        }
                    }
            }
            return completion(.success(userArray))
        }
    }

 */
