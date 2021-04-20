//
//  FeedHeaderView.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 2/2/21.
//

import UIKit

class FeedHeaderView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .systemRed
    }

}
