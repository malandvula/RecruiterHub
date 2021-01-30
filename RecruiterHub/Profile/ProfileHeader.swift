//
//  ProfileHeader.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/14/21.
//
//

import UIKit

protocol ProfileHeaderDelegate: AnyObject {
    func didTapContactInfo(_ header: ProfileHeader)
    func didTapReload(_ header: ProfileHeader)
}

final class ProfileHeader: UICollectionReusableView, UINavigationControllerDelegate {
    static let identifier = "ProfileHeader"
    
    public weak var delegate: ProfileHeaderDelegate?
    
    private let user = RHUser(username: "None",
                              firstName: "Ryan",
                              lastName: "Helgeson",
                              emailAddress: "ryanhelgeson14@gmail.com",
                              positions: ["RHP", "OF", "1B"],
                              highShcool: "Minnetonka",
                              state: "MN",
                              gradYear: 2014,
                              heightFeet: 6,
                              heightInches: 6,
                              weight: 240,
                              arm: "R",
                              bats: "R",
                              profilePicUrl: "https://firebasestorage.googleapis.com/v0/b/recruiterhub-cb0ef.appspot.com/o/bruss1-gmail-com%2Fthumbnails%2Fbruss1-gmail-com_Jan%2027,%202021%20at%209:15:41%20PM%20CST.png?alt=media&token=d17ee630-9e3d-48b8-9a5d-499cd7db8500")
    
    private let profilePhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
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
    
    private let viewContactInfoButton:UIButton = {
        let button = UIButton()
        button.backgroundColor = .link
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Contact Info", for: .normal)
        return button
    }()
    
    private let reloadButton:UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Reload", for: .normal)
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
        backgroundColor = UIColor(patternImage: UIImage(named: "gradient")!)
        viewContactInfoButton.addTarget(self, action: #selector(didTapContactInfo), for: .touchUpInside)
        
        reloadButton.addTarget(self, action: #selector(didTapReloadButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapContactInfo() {
        delegate?.didTapContactInfo(self)
    }
    
    @objc private func didTapReloadButton() {
        delegate?.didTapReload(self)
    }
    
    private func addSubviews() {
        addSubview(profilePhotoImageView)
        addSubview(nameLabel)
        addSubview(positionLabel)
        addSubview(gradLabel)
        addSubview(bodyLabel)
        addSubview(handLabel)
        addSubview(viewContactInfoButton)
        addSubview(reloadButton)
    }
    
    public func configure(user: RHUser) {
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
        
        do {
            if let url = URL(string: user.profilePicUrl) {
                let data = try Data(contentsOf: url)
                profilePhotoImageView.image = UIImage(data: data)
            }
        }
        catch {
            print("Caught Error")
        }
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
        
        viewContactInfoButton.frame = CGRect(x: 20,
                                             y: handLabel.bottom + 5,
                                             width: width - 40,
                                             height: 20)
        viewContactInfoButton.layer.cornerRadius = 3.0

        reloadButton.frame = CGRect(x: 20,
                                             y: viewContactInfoButton.bottom + 5,
                                             width: width - 40,
                                             height: 20)
        reloadButton.layer.cornerRadius = 3.0
        
    }
    
}
