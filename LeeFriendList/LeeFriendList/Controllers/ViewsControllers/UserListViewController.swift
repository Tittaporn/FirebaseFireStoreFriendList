//
//  UserListViewController.swift
//  LeeFriendList
//
//  Created by Lee McCormick on 3/16/21.
//

import UIKit
import FirebaseAuth

class UserListViewController: UIViewController{
    
    // MARK: - Outlets
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var currentUser: User?
    var users: [User] = []
    
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.usernameLabel.text = currentUser?.firstName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let  vc = storyboard.instantiateViewController(identifier: "signupVCStroryboardID")
            self.present( vc, animated: true, completion: nil)
            print("==================SUCCESSFULLY SIGN OUT=======================")
        } catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")        }
    }
    
    // MARK: - Helper Fuctions
    func setupView() {
        DispatchQueue.main.async {
            UserController.shared.fetchAllUsers { (results) in
                switch results {
                case .success(let users):
                    self.users = users
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
            UserController.shared.fetchCurrentUser { (results) in
                switch results {
                case .success(let currentUser):
                    self.usernameLabel.text = currentUser.firstName
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension UserListViewController: UITableViewDataSource, UITableViewDelegate  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("----------------- users.count :: \(users.count)-----------------")
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as? UserTableViewCell else {return UITableViewCell()}
        let user = users[indexPath.row]
        cell.updateView(user: user)
        cell.delegate = self
        return cell
    }
}

// MARK: - Protocol
extension UserListViewController: UserTableViewCellDelagate {
    func requestButtonTapped(sender: UserTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender) else {return}
        let userToRequest = users[indexPath.row]
        UserController.shared.sendFriendRequest(to: userToRequest) { (results) in
            switch results {
            case .success(let userToRequest):
                print("===== SUCCESSFULLY SENT FRIEND REQUEST!!\(self.currentUser?.firstName) is requesting \(userToRequest.firstName) to be a friend. \(#function)======")
            case .failure(let error):
                print("ERROR REQUESTING FRIEND in  \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
}

/*
 func setupView() {
 var blockedUsers: [User] = []
 var allUsers: [User] = []
 DispatchQueue.main.async {
 UserController.shared.fetchAllUsers { (results) in
 switch results {
 case .success(let users):
 allUsers = users
 print("-----------------allUsers count :: \(allUsers.count)-----------------")
 self.tableView.reloadData()
 case .failure(let error):
 print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
 }
 }
 UserController.shared.fetchCurrentUser { (results) in
 switch results {
 case .success(let currentUser):
 self.usernameLabel.text = currentUser.firstName
 UserController.shared.fetchBlockedUsersToFetchAllUser(currentUser) { (results) in
 switch results {
 case .success(let fetchedBlockedUsers):
 blockedUsers = fetchedBlockedUsers
 print("-----------------blockedUsers count :: \(blockedUsers.count)-----------------")
 case .failure(let error):
 print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
 }
 }
 
 case .failure(let error):
 print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
 }
 }
 }
 }
 }
 */

/* NOTE NEED HELPED DEBUGGING
 UI NEEDED TO UPDATE
 1) When block/unfriend tableView need to update on FriendListVC
 2) When unblock tableView need to update on Blocked
 3) UserController need a fetchUsersForCurrentUser function to fetch only users that are not blocked each other and not friends of each other and not current user.
 4) Implement the function on User
 //______________________________________________________________________________________
 */
