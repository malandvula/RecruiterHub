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
    
    private var player: AVPlayer?
    private var playerLayer = AVPlayerLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .done, target: self, action: #selector(didTapBack))
        // Do any additional setup after loading the view.
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        //3. Create AVPlayerLayer object
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        
        //4. Add playerLayer to view's layer
        view.layer.addSublayer(playerLayer)
        playerLayer.player = player
        player?.play()
    }
    
    override func viewDidLayoutSubviews() {
        playerLayer.frame = view.bounds
    }
    
    init(post: Post) {
        self.url = post.url
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapBack() {
        self.dismiss(animated: true, completion: nil)
    }
}

struct Post {
    let title: String
    let url: URL
}
