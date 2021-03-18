//
//  ReceivedListViewController.swift
//  LeeFriendList
//
//  Created by Lee McCormick on 3/16/21.
//

import UIKit

class ReceivedListViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    // MARK: - Properties
    var friendRequestsReceived: [User] = []
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
                    UserController.shared.fetchFriendRequestsReceived(currentUser: currenUser) { (results) in
                        switch results {
                        case .success(let friendsReceived):
                            self.friendRequestsReceived = friendsReceived
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
extension ReceivedListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendRequestsReceived.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "receivedCell") as? ReceiveTableViewCell else {return UITableViewCell()}
        let friendRequestReveived = friendRequestsReceived[indexPath.row]
        cell.updateView(friendRequestReceived: friendRequestReveived)
        cell.delegate = self
        return cell
    }
}

extension ReceivedListViewController: ReceiveTableViewCellDelagate {
    func acceptFriendButtonTapped(sender: ReceiveTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender) else {return}
        let friendsToAccept = friendRequestsReceived[indexPath.row]
        //TO ACCEPT FRIEND HERE...
        UserController.shared.acceptFriendRequest(user: friendsToAccept) { (results) in
            DispatchQueue.main.async {
                switch results {
                case .success(let friend):
                    guard let indexOFfriendToRemove = self.friendRequestsReceived.firstIndex(of: friend) else {return}
                    self.friendRequestsReceived.remove(at: indexOFfriendToRemove)
                    self.tableView.reloadData()
                    self.setupView()
                case .failure(let error):
                    print("ERROR ACCEPTING FRIEND IN \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
}
