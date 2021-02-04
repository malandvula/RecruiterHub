//
//  FeedHeaderCell.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 2/2/21.
//

import UIKit

protocol FeedHeaderCellDelegate: AnyObject {
    func didTapUsername(_ feedHeaderCell: FeedHeaderCell, user: RHUser)
}

class FeedHeaderCell: UITableViewCell {
    
    static let identifier = "FeedHeaderCell"
    
    public weak var delegate: FeedHeaderCellDelegate?
    
    private var user: RHUser?
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let profilePicImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        let gesture = UIGestureRecognizer(target: self, action: #selector(didTapUsername))
        usernameLabel.addGestureRecognizer(gesture)
        addSubview(profilePicImageView)
        
        addSubview(usernameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let padding = 5
        profilePicImageView.frame = CGRect(x: 10,
                                           y: padding,
                                           width: 40,
                                           height: Int(contentView.height) -  (padding * 2) )
        profilePicImageView.layer.cornerRadius = profilePicImageView.width / 2
        
        usernameLabel.frame = CGRect(x: Int(profilePicImageView.right) + 10,
                                     y: padding,
                                     width: Int(contentView.width),
                                     height: Int(contentView.height) -  (padding * 2) )
    }
 
    public func configure(user: RHUser) {

        usernameLabel.text = user.username

        do {
            if let url = URL(string: user.profilePicUrl) {
                let data = try Data(contentsOf: url)
                profilePicImageView.image = UIImage(data: data)
            }
        }
        catch {

        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    @objc private func didTapUsername() {
        print("tapped username")
        guard let user = user else {
            print("User was empty")
            return
        }
        
        delegate?.didTapUsername(self, user: user)
    }
    
    public func getUser() -> RHUser? {
        return user
    }
}
