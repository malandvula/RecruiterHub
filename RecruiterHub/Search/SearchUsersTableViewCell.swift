//
//  SearchUsersTableViewCell.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/25/21.
//

import UIKit

class SearchUsersTableViewCell: UITableViewCell {

    static let identifier = "SearchUsersTableViewCell"
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        nameLabel.text = "Name"
        usernameLabel.text = "Username"
        addSubview(nameLabel)
        addSubview(usernameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.frame = CGRect(x: 10, y: 10, width: width/2, height: 20)
        usernameLabel.frame = CGRect(x: 10, y: nameLabel.bottom + 10, width: width/2, height: 20)
    }
    
}
