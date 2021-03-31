//
//  BatterGameLogTableViewCell.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 3/28/21.
//

import UIKit

class BatterGameLogTableViewCell: UITableViewCell {

    static let identifier = "BatterGameLogTableViewCell"
    
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
    
    private let atBatsLabel: UILabel = {
        let label = UILabel()
        label.text = "AB"
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
    
    private let rbisLabel: UILabel = {
        let label = UILabel()
        label.text = "RBI"
        return label
    }()
    
    private let doublesLabel: UILabel = {
        let label = UILabel()
        label.text = "2B"
        return label
    }()
    
    private let triplesLabel: UILabel = {
        let label = UILabel()
        label.text = "3B"
        return label
    }()
    
    private let homeRunsLabel: UILabel = {
        let label = UILabel()
        label.text = "HR"
        return label
    }()
    
    private let strikeoutsLabel: UILabel = {
        let label = UILabel()
        label.text = "K"
        return label
    }()
    
    private let walksLabel: UILabel = {
        let label = UILabel()
        label.text = "BB"
        return label
    }()

    private let stolenBasesLabel: UILabel = {
        let label = UILabel()
        label.text = "SB"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        contentView.addSubview(dateLabel)
        contentView.addSubview(opponentLabel)
        contentView.addSubview(atBatsLabel)
        contentView.addSubview(hitsLabel)
        contentView.addSubview(runsLabel)
        contentView.addSubview(rbisLabel)
        contentView.addSubview(doublesLabel)
        contentView.addSubview(triplesLabel)
        contentView.addSubview(homeRunsLabel)
        contentView.addSubview(strikeoutsLabel)
        contentView.addSubview(walksLabel)
        contentView.addSubview(stolenBasesLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        dateLabel.frame = CGRect(x: 10, y: 0, width: 100, height: contentView.height - 1)
        
        
        opponentLabel.frame = CGRect(x: dateLabel.right, y: 0, width: 100, height: contentView.height - 1)
        
        atBatsLabel.frame = CGRect(x: opponentLabel.right, y: 0, width: 40, height: contentView.height - 1)
        hitsLabel.frame = CGRect(x: atBatsLabel.right, y: 0, width: 40, height: contentView.height - 1)
        runsLabel.frame = CGRect(x: hitsLabel.right, y: 0, width: 40, height: contentView.height - 1)
        rbisLabel.frame = CGRect(x: runsLabel.right, y: 0, width: 40, height: contentView.height - 1)
        doublesLabel.frame = CGRect(x: rbisLabel.right, y: 0, width: 40, height: contentView.height - 1)
        triplesLabel.frame = CGRect(x: doublesLabel.right, y: 0, width: 40, height: contentView.height - 1)
        homeRunsLabel.frame = CGRect(x: triplesLabel.right, y: 0, width: 40, height: contentView.height - 1)
        strikeoutsLabel.frame = CGRect(x: homeRunsLabel.right, y: 0, width: 40, height: contentView.height - 1)
        walksLabel.frame = CGRect(x: strikeoutsLabel.right, y: 0, width: 40, height: contentView.height - 1)
        stolenBasesLabel.frame = CGRect(x: walksLabel.right, y: 0, width: 40, height: contentView.height - 1)
    }
    
    public func configure(game: BatterGameLog) {
        dateLabel.text = game.date
        opponentLabel.text = game.opponent
        atBatsLabel.text = String(game.atBats)
        hitsLabel.text = String(game.hits)
        runsLabel.text = String(game.runs)
        rbisLabel.text = String(game.rbis)
        doublesLabel.text = String(game.doubles)
        triplesLabel.text = String(game.triples)
        homeRunsLabel.text = String(game.homeRuns)
        strikeoutsLabel.text = String(game.strikeouts)
        walksLabel.text = String(game.walks)
        stolenBasesLabel.text = String(game.stolenBases)
    }
    
}
