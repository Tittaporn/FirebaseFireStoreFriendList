//
//  ReceiveTableViewCell.swift
//  LeeFriendList
//
//  Created by Lee McCormick on 3/16/21.
//


import UIKit
protocol ReceiveTableViewCellDelagate: AnyObject {
    func acceptFriendButtonTapped(sender: ReceiveTableViewCell)
}

class ReceiveTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var acceptedButton: UIButton!
    
    // MARK: - Properties
    var friendRequestReceived: User? {
        didSet {
            updateView(friendRequestReceived: friendRequestReceived!)
        }
    }
    weak var delegate: ReceiveTableViewCellDelagate?
    
    // MARK: - Actions
    @IBAction func acceptedButtonTapped(_ sender: Any) {
        delegate?.acceptFriendButtonTapped(sender: self)
    }
    
    // MARK: - Helper Fuctions
    func updateView(friendRequestReceived: User) {
        nameLabel.text = friendRequestReceived.firstName
    }
}
