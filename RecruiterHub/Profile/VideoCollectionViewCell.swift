//
//  VideoCollectionViewCell.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/21/21.
//

import UIKit
import AVFoundation
import SDWebImage

class VideoCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "VideCollectionViewCell"
    
    private var url: URL?
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = nil
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.layer.borderWidth = 5
        imageView.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        imageView.transform = CGAffineTransform(rotationAngle: .pi / 2)
        return imageView
    }()
    
    private var player: AVPlayer?
    private var playerLayer = AVPlayerLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
        contentView.addSubview(postImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with url: URL) {
        postImageView.sd_setImage(with: url, completed: nil)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        postImageView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.image = nil
    }
}
