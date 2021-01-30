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
    
    private let likeButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        let image = UIImage(systemName: "cpu", withConfiguration: config)
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let likesLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private var player: AVPlayer?
    private var playerLayer = AVPlayerLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)

        // Do any additional setup after loading the view.
        let asset = AVAsset(url: post.url)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        //3. Create AVPlayerLayer object
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        
        //4. Add playerLayer to view's layer
        view.layer.addSublayer(playerLayer)
        view.addSubview(likeButton)
        view.addSubview(likesLabel)
        configureLikesLabel()
        playerLayer.player = player
        player?.play()
        
    }
    
    override func viewDidLayoutSubviews() {
        playerLayer.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.height / 2)
        
        likeButton.frame = CGRect(x: 10,
                                  y: view.safeAreaInsets.top + playerLayer.frame.height,
                                  width: 30,
                                  height: 30)
        
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
        
        // Cast the user email to a String
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentUsername = UserDefaults.standard.value(forKey: "username") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String
        else {
            print("Failed to get User Defaults")
            return
        }
        
        let postLike = PostLike(username: currentUsername, email: currentEmail.safeDatabaseKey(), name: currentName)
        
        // Update the like status
        DatabaseManager.shared.like(with: user.emailAddress.safeDatabaseKey(),
                                    likerInfo: postLike,
                                    postNumber: post.number)
    }
    
    private func configureLikesLabel() {
        let numberOfLikes = post.likes.count
        likesLabel.text = "\(numberOfLikes) likes"
        
        likesLabel.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapLikesLabel))
        likesLabel.addGestureRecognizer(gesture)
    }
    
    @objc private func didTapLikesLabel() {
        let vc = ListViewController(data: post.likes)
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
