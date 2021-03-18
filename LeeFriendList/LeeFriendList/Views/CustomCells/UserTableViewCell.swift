//
//  UserTableViewCell.swift
//  LeeFriendList
//
//  Created by Lee McCormick on 3/16/21.
//

import UIKit

protocol UserTableViewCellDelagate: AnyObject {
    func requestButtonTapped(sender: UserTableViewCell)
}

class UserTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    // MARK: - Properties
    var user: User? {
        didSet {
            updateView(user: user!)
        }
    }
    
    // MARK: - Properties
    weak var delegate: UserTableViewCellDelagate?
    
    @IBAction func requestButtonTapped(_ sender: Any) {
        delegate?.requestButtonTapped(sender: self)
    }
    
    // MARK: - Helper Fuctions
    func updateView(user: User) {
        nameLabel.text = user.firstName
    }
}
