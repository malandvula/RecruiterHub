//
//  ProfileConnections.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/31/21.
//

import UIKit

protocol ProfileConnectionsDelegate: AnyObject {
    func didTapFollowingButton(_ profileConnections: ProfileConnections)
    func didTapFollowersButton(_ profileConnections: ProfileConnections)
    func didTapConnectionsButton(_ profileConnections: ProfileConnections)
}

class ProfileConnections: UICollectionReusableView {
    static let identifier = "ProfileConnections"
    
    public weak var delegate: ProfileConnectionsDelegate?
    
    struct Constants {
        static let padding: CGFloat = 8
    }
    
    private let followersButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.tintColor = .systemBlue
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("Followers", for: .normal)
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.borderWidth = 2
        return button
    }()
    
    private let connectionsButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.tintColor = .systemBlue
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("Connections", for: .normal)
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.borderWidth = 2
        return button
    }()
    
    private let followingButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("Following", for: .normal)
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.borderWidth = 2
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(followingButton)
        addSubview(followersButton)
        addSubview(connectionsButton)
        
        backgroundColor = .black
        
        followingButton.addTarget(self,
                             action: #selector(didTapFollowing),
                             for: .touchUpInside)

        followersButton.addTarget(self,
                             action: #selector(didTapFollowers),
                             for: .touchUpInside)
        
        connectionsButton.addTarget(self,
                             action: #selector(didTapConnections),
                             for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = height - 30
        let thirdWidth = width / 3
        let buttonWidth = width / 3 - 20
        followingButton.frame = CGRect(x: 10,
                                  y: Constants.padding,
                                  width: buttonWidth,
                                    height: size)
        followersButton.frame = CGRect(x: thirdWidth + 10 ,
                                    y: Constants.padding,
                                    width: buttonWidth,
                                    height: size)
        connectionsButton.frame = CGRect(x: thirdWidth * 2 + 10,
                                         y: Constants.padding,
                                         width: buttonWidth,
                                         height: size)
        
    }
    
    @objc private func didTapFollowing() {
        delegate?.didTapFollowingButton(self)
    }
    
    @objc private func didTapFollowers() {
        delegate?.didTapFollowersButton(self)
    }
    
    @objc private func didTapConnections() {
        delegate?.didTapConnectionsButton(self)
    }
}

