//
//  FeedPostInfoCell.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 2/3/21.
//

import UIKit

class FeedPostInfoCell: UITableViewCell {
    static let identifier = "FeedPostInfoCell"
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    override init(style:UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(commentLabel)
        contentView.backgroundColor = .systemOrange
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(email: String, url: String) {
        // Configure the cell
        DatabaseManager.shared.getAllUserPosts(with: email, completion: { [weak self]
            posts in
            guard let posts = posts else {
                return
            }
            
            var index = 0
            for post in posts {
                guard let postUrl = post["url"] as? String else {
                    return
                }
                
                if postUrl == url {
                    print("Found url")
                    self?.contentView.backgroundColor = .systemBackground
                    break
                }
                else {
                    index += 1
                }
            }
            
            DatabaseManager.shared.getComments(with: email, index: index, completion: { comments in
                if comments != nil {
                    self?.usernameLabel.text = comments?[0]["email"]
                    self?.commentLabel.text = comments?[0]["comment"]
                }
            })
        })
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        usernameLabel.frame = CGRect(x: 10, y: 10, width: 100, height: 25)
        commentLabel.frame = CGRect(x: usernameLabel.right + 3, y: 10, width: contentView.width - usernameLabel.right , height: 25)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = ""
        commentLabel.text = ""
    }
}
