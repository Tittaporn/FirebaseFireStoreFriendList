//
//  FriendTableViewCell.swift
//  LeeFriendList
//
//  Created by Lee McCormick on 3/16/21.
//

import UIKit

protocol FriendTableViewCellCellDelagate: AnyObject {
    func blockFriendButtonTapped(sender: FriendTableViewCell)
    func unfriendButtonTapped(sender: FriendTableViewCell)
}

class FriendTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: - Properties
    var friend: User? {
        didSet {
            updateView(friend: friend!)
        }
    }
    
    weak var delegate: FriendTableViewCellCellDelagate?
    
    // MARK: - Actions
    @IBAction func blockedButtonTapped(_ sender: Any) {
        delegate?.blockFriendButtonTapped(sender: self)
    }
    
    @IBAction func unfriendButtonTapped(_ sender: Any) {
        delegate?.unfriendButtonTapped(sender: self)
    }
    
    // MARK: - Helper Fuctions
    func updateView(friend: User) {
        nameLabel.text = friend.firstName
    }
}
