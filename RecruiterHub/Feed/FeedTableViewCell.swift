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
 
    public func configure(post: Post, user: RHUser) {
        
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
        player = nil
        playerLayer.player = player
    }

    public func getUser() -> RHUser? {
        return user
    }
}
