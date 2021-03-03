//
//  FeedActionsCell.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 2/3/21.
//

import UIKit

protocol FeedActionsCellDelegate: AnyObject {
    func didTapLikeButton()
    func didTapCommentButton(email: String, url: String)
    func didTapSendButton()
}

class FeedActionsCell: UITableViewCell {
   
    weak var delegate: FeedActionsCellDelegate?
    
    static let identifier = "FeedActionsCell"
    
    private var url: String?
    
    private var email: String?
    
    private let commentButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        let image = UIImage(systemName: "message", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .label
        return button
    }()

    
    private let likeButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        let image = UIImage(systemName: "heart", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .label
        return button
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        let image = UIImage(systemName: "paperplane", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .label
        return button
    }()

    
    override init(style:UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        contentView.addSubview(sendButton)
        
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapCommentButton), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapLikeButton() {
        guard let email = email else {
            return
        }
        
        DatabaseManager.shared.getAllUserPosts(with: email, completion: {
            [weak self] posts in
            guard let posts = posts else {
                return
            }
            var index = 0
            for post in posts {
                if post["url"] as? String == self?.url {
                    break
                }
                index += 1
            }
            
            if posts.count <= index {
                print("Post doesnt exist")
                return
            }
            
            guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
                  let currentUsername = UserDefaults.standard.value(forKey: "username") as? String,
                  let currentName = UserDefaults.standard.value(forKey: "name") as? String
            else {
                print("Failed to get User Defaults")
                return
            }
            
            // Create Post Like
            let postLike = PostLike(username: currentUsername, email: currentEmail.safeDatabaseKey(), name: currentName)
            
            DatabaseManager.shared.like(with: email, likerInfo: postLike, postNumber: index)
            
            self?.toggleLike()
        })
    
        delegate?.didTapLikeButton()
    }
    
    @objc private func didTapCommentButton() {
        
        guard let email = email else {
            return
        }
        
        guard let url = url else {
            return
        }
        
        delegate?.didTapCommentButton(email: email, url: url)
        
//        DatabaseManager.shared.getAllUserPosts(with: email, completion: {
//            [weak self] posts in
//            guard let posts = posts else {
//                return
//            }
//            var index = 0
//            for post in posts {
//                if post["url"] as? String == self?.url {
//                    break
//                }
//                index += 1
//            }
//            
//            if posts.count <= index {
//                print("Post doesnt exist")
//                return
//            }
//            
//            guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
//                  let currentUsername = UserDefaults.standard.value(forKey: "username") as? String,
//                  let currentName = UserDefaults.standard.value(forKey: "name") as? String
//            else {
//                print("Failed to get User Defaults")
//                return
//            }
//            
//        })
    }
    
    @objc private func didTapSendButton() {
        delegate?.didTapSendButton()
    }
    
    public func configure( with urlString: String, email: String) {
        // Configure the cell
        url = urlString
        self.email = email
        
        DatabaseManager.shared.getAllUserPosts(with: email, completion: {
            [weak self] posts in
            guard let posts = posts else {
                return
            }
            var index = 0
            for post in posts {
                if post["url"] as? String == self?.url {
                    break
                }
                index += 1
            }
            
            if posts.count <= index {
                print("Post doesnt exist")
                return
            }
            
            guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String
            else {
                print("Failed to get User Defaults")
                return
            }
            
            DatabaseManager.shared.getLikes(with: email, index: index, completion: {
                [weak self] likes in
                guard let likes = likes else {
                    return
                }
                for like in likes {
                    if like["email"] == currentEmail {
                        self?.toggleLike()
                    }
                }
            })
            
        })
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // like comment send
        let buttonSize = contentView.height-10
        
        let buttons =  [likeButton, commentButton, sendButton]
        
        for x in 0..<buttons.count {
            let button = buttons[x]
            button.frame = CGRect(x: (CGFloat(x) * buttonSize) + (10*CGFloat(x+1)),
                                  y: 5,
                                  width: buttonSize,
                                  height: buttonSize)
        }
    }
    
    private func toggleLike() {
        if likeButton.tintColor.accessibilityName == UIColor.label.accessibilityName {
            let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
            let image = UIImage(systemName: "heart.fill", withConfiguration: config)
            self.likeButton.setImage(image, for: .normal)
            self.likeButton.tintColor = .red
        }
        else {
          defaultButton()
        }
    }
    
    private func defaultButton() {
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        let image = UIImage(systemName: "heart", withConfiguration: config)
        self.likeButton.setImage(image, for: .normal)
        self.likeButton.tintColor = .label
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        defaultButton()
    }
}
