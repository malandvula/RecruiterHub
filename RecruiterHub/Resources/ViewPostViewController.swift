//
//  ViewPostViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/22/21.
//

import UIKit
import AVFoundation

class ViewPostViewController: UIViewController {

    private var post: Post
    private let user: RHUser
    
    // Like button
    private let likeButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        let image = UIImage(systemName: "cpu", withConfiguration: config)
        button.setImage(image, for: .normal)
        return button
    }()
    
    // Likes label
    private let likesLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        return label
    }()
    
    // Player
    private var player: AVPlayer?
    private var playerLayer = AVPlayerLayer()
    
    // Occurs then the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add like button function call
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)

        let asset = AVAsset(url: post.url)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        // AVPlayer Layer Configuration
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        
        // Add subviews and layers
        view.layer.addSublayer(playerLayer)
        view.addSubview(likeButton)
        view.addSubview(likesLabel)
        
        // Configure likes label
        configureLikesLabel()
        
        // Add player and start playing
        playerLayer.player = player
        player?.play()
        
    }
    
    // Design layout
    override func viewDidLayoutSubviews() {
        
        // Place player layer
        playerLayer.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.height / 2)
        
        // Place like button
        likeButton.frame = CGRect(x: 10,
                                  y: view.safeAreaInsets.top + playerLayer.frame.height,
                                  width: 30,
                                  height: 30)
        
        // Place likes label
        likesLabel.frame = CGRect(x: 10, y: likeButton.bottom + 10, width: view.width - 20, height: 20)
    }
    
    /// ViewPostViewController initializer, sets the post, user, and postnumber
    init(post: Post, user: RHUser) {
        self.post = post
        self.user = user
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    // Required init function
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Function that is called when the like button is tapped
    @objc private func didTapLike() {
        print("Tapped Like")
        
        // Cast the user info to Strings
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentUsername = UserDefaults.standard.value(forKey: "username") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String
        else {
            print("Failed to get User Defaults")
            return
        }
        
        // Create Post Like
        let postLike = PostLike(username: currentUsername, email: currentEmail.safeDatabaseKey(), name: currentName)
        
        // Update the like status
        DatabaseManager.shared.like(with: user.emailAddress.safeDatabaseKey(),
                                    likerInfo: postLike,
                                    postNumber: post.number)
    }
    
    // Configure the like button
    private func configureLikesLabel() {
        let numberOfLikes = post.likes.count
        likesLabel.text = "\(numberOfLikes) likes"
        
        likesLabel.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapLikesLabel))
        likesLabel.addGestureRecognizer(gesture)
    }
    
    // Callback for like label interaction
    @objc private func didTapLikesLabel() {
        var likes: [[String:String]] = []
        for like in post.likes {
            let newElement = ["email":like.email]
            likes.append(newElement)
        }
        let vc = ListsViewController(data: likes)
        vc.title = "Likes"
        navigationController?.pushViewController(vc, animated: true)
    }
}

// Structure that holds all information related to a post
struct Post {
    let likes: [PostLike]
    let title: String
    let url: URL
    let number: Int
}

public struct PostLike: Equatable {
    let username: String
    let email: String
    let name: String
}
