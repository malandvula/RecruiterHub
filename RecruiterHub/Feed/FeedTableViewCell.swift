//
//  FeedTableViewCell.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/30/21.
//

import UIKit
import AVFoundation

protocol FeedTableViewCellDelegate: AnyObject {
    
}


class FeedTableViewCell: UITableViewCell {

    static let identifier = "FeedTableViewCell"
    
    public weak var delegate: FeedTableViewCellDelegate?
    
    private var user: RHUser?
    
    private var player: AVPlayer?
    private var playerLayer = AVPlayerLayer()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        //3. Create AVPlayerLayer object
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        
        layer.addSublayer(playerLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        playerLayer.frame = CGRect(x: 0,
                                   y: 0,
                                   width: contentView.width,
                                   height: contentView.height)
    }
 
    public func configure(post: Post) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // Do any additional setup after loading the view.
            let asset = AVAsset(url: post.url)
            let playerItem = AVPlayerItem(asset: asset)
            self?.player = AVPlayer(playerItem: playerItem)
            
            self?.playerLayer.player = self?.player
        }
        //4. Add playerLayer to view's layer
    }
    
    public func configure(url: AVPlayer) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // Do any additional setup after loading the view.
            self?.player = url
            self?.playerLayer.player = self?.player
        }
        //4. Add playerLayer to view's layer
    }
    
    public func play() {
        if player?.rate != 0 {
            print("Playing")
        }
        else {
            if player?.currentTime().seconds != 0 {
                player?.seek(to: CMTime(seconds: 0.0, preferredTimescale: 1))
            }
            player?.play()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        player = nil
        playerLayer.player = nil
    }

    public func getUser() -> RHUser? {
        return user
    }
}
