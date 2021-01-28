//
//  ViewPostViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/22/21.
//

import UIKit
import AVFoundation

class ViewPostViewController: UIViewController {

    private var url: URL
    private let user: RHUser
    private let postNumber: Int
    
    private let likeButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        let image = UIImage(systemName: "cpu", withConfiguration: config)
        button.setImage(image, for: .normal)
        return button
    }()
    
    private var player: AVPlayer?
    private var playerLayer = AVPlayerLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .done, target: self, action: #selector(didTapBack))
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)

        // Do any additional setup after loading the view.
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        //3. Create AVPlayerLayer object
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        
        //4. Add playerLayer to view's layer
        view.layer.addSublayer(playerLayer)
        view.addSubview(likeButton)
        playerLayer.player = player
        player?.play()
    }
    
    override func viewDidLayoutSubviews() {
        playerLayer.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.height / 2)
        
        likeButton.frame = CGRect(x: 10,
                                  y: view.safeAreaInsets.top + playerLayer.frame.height,
                                  width: 30,
                                  height: 30)
    }
    
    init(post: Post, user: RHUser, postNumber: Int) {
        self.url = post.url
        self.user = user
        self.postNumber = postNumber
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapLike() {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String  else {
            return
        }
        DatabaseManager.shared.like(with: user.emailAddress.safeDatabaseKey(),
                                    likerEmail: currentEmail,
                                    postNumber: postNumber)
    }
}

struct Post {
    let likes: [String]
    let title: String
    let url: URL
}
