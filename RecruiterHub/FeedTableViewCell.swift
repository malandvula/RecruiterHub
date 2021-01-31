//
//  FeedTableViewCell.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/30/21.
//

import UIKit
import AVFoundation

protocol FeedTableViewCellDelegate: AnyObject {
    func didTapUsername(_ feedTableViewCell: FeedTableViewCell, user: RHUser)
}


class FeedTableViewCell: UITableViewCell {

    static let identifier = "FeedTableViewCell"
    
    public weak var delegate: FeedTableViewCellDelegate?
    
    private var user: RHUser?
    
    private var player: AVPlayer?
    private var playerLayer = AVPlayerLayer()
    
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
        
        profilePicImageView.frame = CGRect(x: 5, y: 10, width: 40, height: 40)
        profilePicImageView.layer.cornerRadius = profilePicImageView.width / 2
        
        usernameLabel.frame = CGRect(x: profilePicImageView.right + 10,
                                     y: 0,
                                     width: contentView.width,
                                     height: 60)
        playerLayer.frame = CGRect(x: 0,
                                   y: usernameLabel.bottom,
                                   width: contentView.width,
                                   height: contentView.height - usernameLabel.height)
    }
    
    public func configure(post: Post, user: RHUser) {
    
        usernameLabel.text = user.username
        
        do {
            if let url = URL(string: user.profilePicUrl) {
                let data = try Data(contentsOf: url)
                profilePicImageView.image = UIImage(data: data)
            }
        }
        catch {
            print("Caught Error")
        }
        // Do any additional setup after loading the view.
        let asset = AVAsset(url: post.url)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        //3. Create AVPlayerLayer object
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        
        //4. Add playerLayer to view's layer
        layer.addSublayer(playerLayer)
        playerLayer.player = player
        player?.play()
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
