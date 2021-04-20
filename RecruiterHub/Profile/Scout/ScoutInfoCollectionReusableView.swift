//
//  ScoutInfoCollectionReusableView.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 3/24/21.
//

import UIKit

protocol ScoutInfoDelegate: AnyObject {
    func didTapGameLog(_ header: ScoutInfoCollectionReusableView)
}

final class ScoutInfoCollectionReusableView: UICollectionReusableView, UINavigationControllerDelegate {
    static let identifier = "ScoutInfoCollectionReusableView"
    
    public weak var delegate: ScoutInfoDelegate?
    
    public var size = 0
    
    private let profilePhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        imageView.layer.borderWidth = 5
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let gameLogButton: UIButton =  {
        let button = UIButton(frame: .zero)
        button.setTitle("Game Logs", for: .normal)
        button.setTitleColor(UIColor.link, for: .normal)
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        gameLogButton.addTarget(self, action: #selector(didTapGameLog), for: .touchUpInside)
        
        addSubviews()
        clipsToBounds = true
        backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapGameLog() {
        print("Hello")
        delegate?.didTapGameLog(self)
    }
    
    private func addSubviews() {
        addSubview(profilePhotoImageView)
        addSubview(nameLabel)
        addSubview(gameLogButton)
    }
    
    public func configure(user: RHUser, hideFollowButton: Bool) {
        
        nameLabel.text = user.firstName + " " + user.lastName

        if let url = URL(string: user.profilePicUrl) {
            profilePhotoImageView.sd_setImage(with: url, completed: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let profilePhotoSize = width/3
        profilePhotoImageView.frame = CGRect(x: profilePhotoSize,
                                             y: 5,
                                             width: profilePhotoSize,
                                             height: profilePhotoSize).integral
        profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.width / 4.0
        
        nameLabel.frame = CGRect(x: 10,
                                 y: profilePhotoImageView.bottom + 10,
                                 width: width - 20 ,
                                 height: 28)
        nameLabel.textAlignment = .center
        
        gameLogButton.frame = CGRect(x: 10,
                                 y: nameLabel.bottom + 10,
                                 width: width - 20 ,
                                 height: 28)
    }
    
    public static func getHeight() -> CGFloat {

        return 220.0
    }
}
