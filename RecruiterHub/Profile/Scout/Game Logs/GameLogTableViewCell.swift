//
//  GameLogTableViewCell.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 3/27/21.
//

import UIKit

class GameLogTableViewCell: UITableViewCell {

    static let identifier = "GameLogTableViewCell"
    
    private let opponentLabel: UILabel = {
        let label = UILabel()
        label.text = "Opponent"
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Date"
        return label
    }()
    
    private let inningsPithedLabel: UILabel = {
        let label = UILabel()
        label.text = "IP"
        return label
    }()
    
    private let hitsLabel: UILabel = {
        let label = UILabel()
        label.text = "H"
        return label
    }()
    
    private let runsLabel: UILabel = {
        let label = UILabel()
        label.text = "R"
        return label
    }()
    
    private let earnedRuns: UILabel = {
        let label = UILabel()
        label.text = "ER"
        return label
    }()
    
    private let strikeoutLabel: UILabel = {
        let label = UILabel()
        label.text = "K"
        return label
    }()
    
    private let walkLabel: UILabel = {
        let label = UILabel()
        label.text = "BB"
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        contentView.addSubview(dateLabel)
        contentView.addSubview(opponentLabel)
        contentView.addSubview(inningsPithedLabel)
        contentView.addSubview(hitsLabel)
        contentView.addSubview(runsLabel)
        contentView.addSubview(earnedRuns)
        contentView.addSubview(strikeoutLabel)
        contentView.addSubview(walkLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        dateLabel.frame = CGRect(x: 10, y: 0, width: 100, height: contentView.height - 1)
        
        
        opponentLabel.frame = CGRect(x: dateLabel.right, y: 0, width: 100, height: contentView.height - 1)
        
        inningsPithedLabel.frame = CGRect(x: opponentLabel.right, y: 0, width: 40, height: contentView.height - 1)
        hitsLabel.frame = CGRect(x: inningsPithedLabel.right, y: 0, width: 40, height: contentView.height - 1)
        runsLabel.frame = CGRect(x: hitsLabel.right, y: 0, width: 40, height: contentView.height - 1)
        earnedRuns.frame = CGRect(x: runsLabel.right, y: 0, width: 40, height: contentView.height - 1)
        strikeoutLabel.frame = CGRect(x: earnedRuns.right, y: 0, width: 40, height: contentView.height - 1)
        walkLabel.frame = CGRect(x: strikeoutLabel.right, y: 0, width: 40, height: contentView.height - 1)
    }
    
    public func configure(game: PitcherGameLog) {
        dateLabel.text = game.date
        opponentLabel.text = game.opponent
        inningsPithedLabel.text = String(game.inningsPitched)
        hitsLabel.text = String(game.hits)
        runsLabel.text = String(game.runs)
        earnedRuns.text = String(game.earnedRuns)
        strikeoutLabel.text = String(game.strikeouts)
        walkLabel.text = String(game.walks)
    }
    
}
