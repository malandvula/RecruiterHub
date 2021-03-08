//
//  ScoutCollectionViewCell.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 3/6/21.
//

import UIKit

class ScoutCollectionViewCell: UICollectionViewCell {
    static let identifier = "ScoutCollectionViewCell"
    
    private let attributeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        layer.borderWidth = 5
        layer.cornerRadius = 10
        layer.borderColor = UIColor.secondarySystemBackground.cgColor
        contentView.addSubview(attributeLabel)
        contentView.addSubview(valueLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(email: String, attribute: ScoutAttributes) {
        
        DatabaseManager.shared.getScoutInfoForUser(user: email, completion: { [weak self]
            scoutInfo in
            
            guard let scoutInfo = scoutInfo else {
                switch attribute {
                case .fastball:
                    self?.attributeLabel.text = "FB"
                    break
                case .curveball:
                    self?.attributeLabel.text = "CB"
                    break
                case .slider:
                    self?.attributeLabel.text = "SL"
                    break
                case .changeup:
                    self?.attributeLabel.text = "CH"
                    break
                case .sixty:
                    self?.attributeLabel.text = "60 Time"
                    break
                case .infield:
                    self?.attributeLabel.text = "IF"
                    break
                case .outfield:
                    self?.attributeLabel.text = "OF"
                    break
                case .exitVelo:
                    self?.attributeLabel.text = "Exit Velo"
                    break
                }
                self?.valueLabel.text = "N/A"
                return
            }
            
            var value = 0.0
            switch attribute {
            case .fastball:
                self?.attributeLabel.text = "FB"
                value = scoutInfo.fastball
                break
            case .curveball:
                self?.attributeLabel.text = "CB"
                value = scoutInfo.curveball
                break
            case .slider:
                self?.attributeLabel.text = "SL"
                value = scoutInfo.slider
                break
            case .changeup:
                self?.attributeLabel.text = "CH"
                value = scoutInfo.changeup
                break
            case .sixty:
                self?.attributeLabel.text = "60 Time"
                value = scoutInfo.sixty
                break
            case .infield:
                self?.attributeLabel.text = "IF"
                value = scoutInfo.infield
                break
            case .outfield:
                self?.attributeLabel.text = "OF"
                value = scoutInfo.outfield
                break
            case .exitVelo:
                self?.attributeLabel.text = "Exit Velo"
                value = scoutInfo.exitVelo
                break
            }
            if value == 0.0 {
                self?.valueLabel.text = "N/A"
            }
            else {
                self?.valueLabel.text = String(value)
            }
        })
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        attributeLabel.frame = CGRect(x: 10 , y: contentView.height / 6, width: contentView.width - 20 , height: 20)
        valueLabel.frame = CGRect(x: 10 , y: attributeLabel.bottom + 20, width: contentView.width - 20 , height: 20)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        attributeLabel.text = ""
    }
}

public struct ScoutInfo {
    var fastball: Double
    var curveball: Double
    var slider: Double
    var changeup: Double
    var sixty: Double
    var infield: Double
    var outfield: Double
    var exitVelo: Double
    
    init() {
        fastball = 0.0
        curveball = 0.0
        slider = 0.0
        changeup = 0.0
        sixty = 0.0
        infield = 0.0
        outfield = 0.0
        exitVelo = 0.0
    }
}

public enum ScoutAttributes {
    case fastball
    case curveball
    case slider
    case changeup
    case sixty
    case infield
    case outfield
    case exitVelo
}
