//
//  ProfileTabs.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/31/21.
//

import UIKit

protocol ProfileTabsDelegate: AnyObject {
    func didTapGridButtonTab()
    func didTapScoutButtonTab()
}

class ProfileTabs: UICollectionReusableView {
    static let identifier = "ProfileTabs"
    
    public weak var delegate: ProfileTabsDelegate?
    
    struct Constants {
        static let padding: CGFloat = 8
    }
    
    private let gridButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.tintColor = .systemBlue
        let image = UIImage(systemName: "info.circle")
        button.setBackgroundImage(image, for: .normal)
        return button
    }()
    
    private let scoutButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.tintColor = .systemBlue
        button.setBackgroundImage(UIImage(systemName: "note.text"), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(gridButton)
        addSubview(scoutButton)
        
        gridButton.addTarget(self,
                             action: #selector(didTapGridButton),
                             for: .touchUpInside)

        scoutButton.addTarget(self,
                             action: #selector(didTapTaggedButton),
                             for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = height - (Constants.padding * 2)
        let gridButtonX = ((width/2) - size) / 2
        gridButton.frame = CGRect(x: gridButtonX,
                                  y: Constants.padding,
                                    width: size,
                                    height: size)
        scoutButton.frame = CGRect(x: gridButtonX + (width/2),
                                    y: Constants.padding,
                                    width: size,
                                    height: size)
    }
    
    @objc private func didTapGridButton() {
        delegate?.didTapGridButtonTab()
    }

    @objc private func didTapTaggedButton() {
        delegate?.didTapScoutButtonTab()
    }
}

