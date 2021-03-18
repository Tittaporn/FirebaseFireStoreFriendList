//
//  RequestListViewController.swift
//  LeeFriendList
//
//  Created by Lee McCormick on 3/16/21.
//

import UIKit

class RequestListViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    // MARK: - Properties
    var friendRequestsSent: [User] = []
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
                    UserController.shared.fetchPendingFriendRequestsSentBy(currentUser: currenUser) { (results) in
                        switch results {
                        case .success(let pendingFriendRequests):
                            self.friendRequestsSent = pendingFriendRequests
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
extension RequestListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendRequestsSent.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell") as? RequestTableViewCell else {return UITableViewCell()}
        let friendRequest = friendRequestsSent[indexPath.row]
        cell.updateView(friendRequestSent: friendRequest)
        cell.delegate = self
        return cell
    }
}

// MARK: - Protocol
extension RequestListViewController: RequestTableViewCellDelagate {
    func cancelFriendRequestButtonTapped(sender: RequestTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender) else {return}
        let friendToCancelRequest = friendRequestsSent[indexPath.row]
        //DO CANCEL HERE...
        UserController.shared.cancelFriendRequest(to: friendToCancelRequest) { (results) in
            DispatchQueue.main.async {
                switch results {
                case .success(let friendToCancelRequest):
                    print("SUCCESSFULLY CANCEL \(friendToCancelRequest.firstName) FROM \(self.currentUser?.firstName ?? "")'S LIST.")
                    guard let indexOfRequestCancel = self.friendRequestsSent.firstIndex(of: friendToCancelRequest) else {return}
                    self.friendRequestsSent.remove(at: indexOfRequestCancel)
                    self.setupView()
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    print("ERROR CANCEL FRIEND REQUEST in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
}
