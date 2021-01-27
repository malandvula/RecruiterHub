//
//  ProfileTopBar.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/26/21.
//

import UIKit

protocol ProfileTopBarDelegate: AnyObject {
    func didTapSettingsButton(_ profileTopBar: ProfileTopBar)
}

class ProfileTopBar: UICollectionReusableView {
        
    static public let identifier = "ProfileTopBar"
    
    public weak var delegate: ProfileTopBarDelegate?
    
    private let settingsButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        let image = UIImage(systemName: "gear", withConfiguration: config)
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let infoButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        let image = UIImage(systemName: "info.circle", withConfiguration: config)
        button.setImage(image, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(settingsButton)
        addSubview(infoButton)
        settingsButton.addTarget(self, action: #selector(didTapSettingsButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        settingsButton.frame = CGRect(x: 10, y: 5, width: 20, height: 20)
        
        infoButton.frame = CGRect(x: settingsButton.right + 10, y: 5, width: 20, height: 20)
    }
    
    @objc private func didTapSettingsButton() {
        print("Tapped Settings")
        delegate?.didTapSettingsButton(self)
    }
}
