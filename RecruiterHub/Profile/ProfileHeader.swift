//
//  ProfileHeader.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/14/21.
//
//

import UIKit

protocol ProfileHeaderDelegate: AnyObject {
    func didTapFollowButton(_ header: ProfileHeader)
    func didTapReload(_ header: ProfileHeader)
}

final class ProfileHeader: UICollectionReusableView, UINavigationControllerDelegate {
    static let identifier = "ProfileHeader"
    
    public weak var delegate: ProfileHeaderDelegate?
    
    public var size = 0
    
    private let user = RHUser()
    
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
    
    private let positionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let gradLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let handLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()

    private let reloadButton:UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Reload", for: .normal)
        return button
    }()

    private let followButton:UIButton = {
        let button = UIButton()
        button.backgroundColor = .link
        button.isHidden = true
        button.setTitleColor( .label, for: .normal)
        button.setTitle("Follow", for: .normal)
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        configureGradLabel()
        configureNameLabel()
        configurePositionLabel()
        configureBodyLabels()
        clipsToBounds = true
        backgroundColor = .systemBackground
        reloadButton.addTarget(self, action: #selector(didTapReloadButton), for: .touchUpInside)
        followButton.addTarget(self, action: #selector(didTapFollowButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapReloadButton() {
        delegate?.didTapReload(self)
    }
    
    @objc private func didTapFollowButton() {
        if followButton.titleLabel?.text == "Unfollow" {
            followButton.setTitle("Follow", for: .normal)
            followButton.backgroundColor = .link
        }
        else {
            followButton.setTitle("Unfollow", for: .normal)
            followButton.backgroundColor = .lightGray
        }
        delegate?.didTapFollowButton(self)
    }
    
    private func addSubviews() {
        addSubview(profilePhotoImageView)
        addSubview(nameLabel)
        addSubview(positionLabel)
        addSubview(gradLabel)
        addSubview(bodyLabel)
        addSubview(handLabel)
        addSubview(reloadButton)
        addSubview(followButton)
    }
    
    public func configure(user: RHUser, hideFollowButton: Bool) {
        
        if !hideFollowButton {
            followButton.isHidden = false
        }
        
        nameLabel.text = user.firstName + " " + user.lastName
        guard let gradYear = user.gradYear else {
            gradLabel.text = "Year: N/A"
            return
        }
        gradLabel.text = "Year: " + String(gradYear)
        guard let heightFeet = user.heightFeet,
              let heightInches = user.heightInches,
              let weight = user.weight,
              let arm = user.arm,
              let bats = user.bats else {
            bodyLabel.text = ""
            handLabel.text = ""
            return
        }
        bodyLabel.text = String(heightFeet) + "'" + String(heightInches) + "  "  + String(weight) + " lbs"
        handLabel.text = "Throws: " + String(arm) + "   Bats: " + String(bats)
        var positions = ""
        var x = 0
        for position in user.positions {
            x += 1
            if user.positions.count == x {
                positions.append(position)
            }
            else {
                positions.append(position + ", ")
            }
            
        }
        positionLabel.text = positions
        DispatchQueue.global(qos: .background).async {
            do {
                if let url = URL(string: user.profilePicUrl) {
                    let data = try Data(contentsOf: url)
                    DispatchQueue.main.async {
                        self.profilePhotoImageView.image = UIImage(data: data)
                    }
                }
            }
            catch {
                
            }
        }
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        if email == user.emailAddress.safeDatabaseKey() {
            followButton.isHidden = true
        }
        
        DatabaseManager.shared.getUserFollowing(email: email.safeDatabaseKey(), completion: { [weak self]
            result in
            guard let result = result else {
                return
            }
            if result.contains(["email": user.emailAddress.safeDatabaseKey()]) {
                self?.followButton.setTitle("Unfollow", for: .normal)
                self?.followButton.backgroundColor = .lightGray
            }
        })
    }
    
    private func configureNameLabel() {
//        nameLabel.text = user.firstName + " " + user.lastName
//        nameLabel.font = .systemFont(ofSize: 24, weight: .semibold)
    }
    
    private func configureGradLabel() {
//        guard let gradYear = user.gradYear else {
//            gradLabel.text = "Year: N/A"
//            return
//        }
//        gradLabel.text = "Year: " + String(gradYear)
    }
    
    private func configureBodyLabels() {
//        guard let heightFeet = user.heightFeet,
//              let heightInches = user.heightInches,
//              let weight = user.weight,
//              let arm = user.arm,
//              let bats = user.bats else {
//            bodyLabel.text = ""
//            handLabel.text = ""
//            return
//        }
//        bodyLabel.text = String(heightFeet) + "'" + String(heightInches) + "  "  + String(weight) + " lbs"
//        handLabel.text = "Throws: " + String(arm) + "   Bats: " + String(bats)
    }
    
    private func configurePositionLabel() {
//        var positions = ""
//        var x = 0
//        for position in user.positions {
//            x += 1
//            if user.positions.count == x {
//                positions.append(position)
//            }
//            else {
//                positions.append(position + ", ")
//            }
//            
//        }
//        positionLabel.text = positions
//        print(positions)
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
        positionLabel.frame = CGRect(x: 10,
                                     y: nameLabel.bottom + 5,
                                     width: width - 20,
                                     height: 20)
        positionLabel.textAlignment = .center
        bodyLabel.frame = CGRect(x: 10,
                                 y: positionLabel.bottom + 5,
                                 width: width - 20,
                                 height: 20)
        bodyLabel.textAlignment = .center
        gradLabel.frame = CGRect(x: 10,
                                 y: bodyLabel.bottom + 5,
                                 width: width - 20,
                                 height: 20)
        gradLabel.textAlignment = .center
        
        handLabel.frame = CGRect(x: 10,
                                 y: gradLabel.bottom + 5,
                                 width: width - 20,
                                 height: 20)
        handLabel.textAlignment = .center
        
        reloadButton.frame = CGRect(x: 20,
                                             y: handLabel.bottom + 5,
                                             width: width - 40,
                                             height: 20)
        reloadButton.layer.cornerRadius = 3.0
        followButton.frame = CGRect(x: 20,
                                             y: reloadButton.bottom + 5,
                                             width: width - 40,
                                             height: 20)
        followButton.layer.cornerRadius = 3.0
        
    }
    
}
