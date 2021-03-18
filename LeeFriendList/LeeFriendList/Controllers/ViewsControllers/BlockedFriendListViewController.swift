//
//  BlockedFriendListViewController.swift
//  LeeFriendList
//
//  Created by Lee McCormick on 3/17/21.
//

import UIKit

class BlockedFriendListViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    // MARK: - Properties
    var blockedUsers: [User] = []
    var currentUser: User?
    
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
    // MARK: - Helper Fuctions
    func setupView() {
        UserController.shared.fetchCurrentUser { (results) in
            DispatchQueue.main.async {
                switch results {
                case .success(let currenUser):
                    self.usernameLabel.text = currenUser.firstName
                    self.currentUser = currenUser
                    UserController.shared.fetchBlockedUsersByCurrentUser(currenUser) { (results) in
                        switch results {
                        case .success(let fetchBlockedUserForCurrentUser):
                            self.blockedUsers = fetchBlockedUserForCurrentUser
                            self.tableView.reloadData()
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

// MARK: - UITableViewDataSource, UITableViewDelegate
extension BlockedFriendListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockedUsers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "blockedFriendCell") as? BlockedFriendTableViewCell else {return UITableViewCell()}
        let blockedUser = blockedUsers[indexPath.row]
        cell.updateView(blockedUser: blockedUser)
        cell.delegate = self
        return cell
    }
}

// MARK: - Protocol

extension BlockedFriendListViewController: BlockedFriendTableViewCellDelegate {
    func unblockFriendButtonTapped(sender: BlockedFriendTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender) else {return}
        let userToUnBlock = blockedUsers[indexPath.row]
        //TO UNBLOCK FRIEND HERE...
        UserController.shared.unblockedUser(userToUnBlock) { (results) in
            DispatchQueue.main.async {
                switch results {
                case .success(let user):
                    print("====\(user.firstName)==== GOT UNBLOCK FROM \(self.currentUser?.firstName ?? "").")
                    guard let indexToUnblock = self.blockedUsers.firstIndex(of: user) else {return}
                    self.blockedUsers.remove(at: indexToUnblock)
                    self.tableView.deselectRow(at: indexPath, animated: true)
                    self.tableView.reloadData()
                    self.setupView()
                case .failure(let error):
                    print("ERROR IN UNBLOCKING USER in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
}
 


