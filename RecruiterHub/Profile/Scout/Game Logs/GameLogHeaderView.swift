//
//  GameLogHeaderView.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 4/5/21.
//

import UIKit

protocol GameLogHeaderViewDelegate: AnyObject {
    func didTapSwitch(_ view: GameLogHeaderView)
}

class GameLogHeaderView: UIView {

    public weak var delegate: GameLogHeaderViewDelegate?
    
    private var isBatting = false
    
    let battingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.text = "Batting"
        return label
    }()
    
    let pitchingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .link
        label.text = "Pitching"
        return label
    }()
    
    let button: UIButton = {
        let button = UIButton()
        button.setTitle("Switch", for: .normal)
        button.addTarget(self, action: #selector(didTapSwitch), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        addSubview(battingLabel)
        addSubview(pitchingLabel)
        addSubview(button)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pitchingLabel.frame = CGRect(x: 10, y: 0, width: 80, height: height)
        battingLabel.frame = CGRect(x: pitchingLabel.right, y: 0, width: 70, height: height)
        button.frame = CGRect(x: battingLabel.right, y: 0, width: 70, height: height)
    }
    
    @objc private func didTapSwitch() {
        delegate?.didTapSwitch(self)
        if isBatting == false {
            pitchingLabel.textColor = .label
            battingLabel.textColor = .link
            isBatting = true
        }
        else {
            pitchingLabel.textColor = .link
            battingLabel.textColor = .label
            isBatting = false
        }
    }

}
