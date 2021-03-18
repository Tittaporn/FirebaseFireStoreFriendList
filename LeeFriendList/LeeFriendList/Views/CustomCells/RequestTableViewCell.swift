//
//  RequestTableViewCell.swift
//  LeeFriendList
//
//  Created by Lee McCormick on 3/16/21.
//

import UIKit
protocol RequestTableViewCellDelagate: AnyObject {
    func cancelFriendRequestButtonTapped(sender: RequestTableViewCell)
}

class RequestTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: - Properties
        var friendRequestSent: User? {
            didSet {
                updateView(friendRequestSent: friendRequestSent!)
            }
    }
    
    weak var delegate: RequestTableViewCellDelagate?
    
    // MARK: - Actions
    @IBAction func cancelButtonTapped(_ sender: Any) {
        delegate?.cancelFriendRequestButtonTapped(sender: self)
    }
    
    // MARK: - Helper Fuctions
        func updateView(friendRequestSent: User) {
            nameLabel.text = friendRequestSent.firstName
        }
}
