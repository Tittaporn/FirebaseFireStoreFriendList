//
//  FriendListViewController.swift
//  LeeFriendList
//
//  Created by Lee McCormick on 3/16/21.
//

import UIKit

class FriendListViewController: UIViewController {
    

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    // MARK: - Properties
    var friends: [User] = []
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
                    UserController.shared.fetchFriendsFor(currentUser: currenUser) { (results) in
                        switch results {
                        case .success(let fetchFriends):
                            self.friends = fetchFriends
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
extension FriendListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as? FriendTableViewCell else {return UITableViewCell()}
        let friend = friends[indexPath.row]
        cell.updateView(friend: friend)
        cell.delegate = self
        return cell
    }
}

// MARK: - Protocol
extension FriendListViewController: FriendTableViewCellCellDelagate {
    func unfriendButtonTapped(sender: FriendTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender) else {return}
        let friendToUnfriend = friends[indexPath.row]
        //TO UNFRIENED FRIEND HERE...
        UserController.shared.unfriendUser(friendToUnfriend) { (results) in
            DispatchQueue.main.async {
                switch results {
                case .success(let user):
                    print("====\(user.firstName)==== GOT UNFRIENDED FROM \(self.currentUser?.firstName ?? "").")
                    guard let indexToUnfriend = self.friends.firstIndex(of: user) else {return}
                    self.friends.remove(at: indexToUnfriend)
                    self.tableView.reloadData()
                    self.setupView()
                    //self.setupView()
//                    self.tableView.deleteRows(at: [indexPath], with: .fade)
//                    self.tableView.reloadData()
                case .failure(let error):
                    print("ERROR IN BLOCKING FRIEND in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
    
    func blockFriendButtonTapped(sender: FriendTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender) else {return}
        let friendToBlock = friends[indexPath.row]
        //TO BLOCK FRIEND HERE...
        UserController.shared.blockUser(friendToBlock) { (results) in
            DispatchQueue.main.async {
                switch results {
                case .success(let user):
                    print("====\(user.firstName)==== GOT BLOCK FROM \(self.currentUser?.firstName ?? "").")
                    guard let indexToBlock = self.friends.firstIndex(of: user) else {return}
                    self.friends.remove(at: indexToBlock)
                    self.tableView.reloadData()
                    self.setupView()
                    //self.setupView()
                    //self.tableView.deleteRows(at: [indexPath], with: .fade)
                    //self.tableView.reloadData()
                case .failure(let error):
                    print("ERROR IN BLOCKING FRIEND in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
}


