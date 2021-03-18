//
//  BlockedFriendsTableViewCell.swift
//  LeeFriendList
//
//  Created by Lee McCormick on 3/17/21.
//

import UIKit

protocol BlockedFriendTableViewCellDelegate: AnyObject {
    func unblockFriendButtonTapped(sender: BlockedFriendTableViewCell)
}

class BlockedFriendTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: - Properties
    var blockedUser: User? {
        didSet {
            updateView(blockedUser: blockedUser!)
        }
    }
    
    weak var delegate: BlockedFriendTableViewCellDelegate?
    
    // MARK: - Actions
    @IBAction func unBlockedButtonTapped(_ sender: Any) {
        delegate?.unblockFriendButtonTapped(sender: self)
    }
    
    // MARK: - Helper Fuctions
    func updateView(blockedUser: User) {
        nameLabel.text = blockedUser.firstName
    }
}
