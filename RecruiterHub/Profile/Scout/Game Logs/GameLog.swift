//
//  File.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 3/27/21.
//

import Foundation

public enum GameLog {
    case batting
    case pitching
}

public struct PitcherGameLog {
    var opponent: String
    var date: String
    var inningsPitched: Double
    var hits: Int
    var runs: Int
    var earnedRuns: Int
    var strikeouts: Int
    var walks: Int
    
    var era: Double {
        var games = 0.0;
        let inningNumber = floor(Double(inningsPitched))
        let inningFraction = Int(inningsPitched * 10) % 10
        if inningFraction == 2 {
            games = (inningNumber + 0.67) / 9.0
        }
        else if inningFraction == 1 {
            games = (inningNumber + 0.33) / 9.0
        }
        else {
            games = (inningNumber) / 9.0
        }
        let era = Double(earnedRuns) / games
        
        if era.isNaN {
            return 0.0
        }
        if era.isInfinite {
            return 99.0
        }
        return era
    }
    
    init() {
        opponent = ""
        date = ""
        inningsPitched = 0
        hits = 0
        runs = 0
        earnedRuns = 0
        strikeouts = 0
        walks = 0
    }
}

public struct BatterGameLog {
    var opponent: String
    var date: String
    var atBats: Int
    var hits: Int
    var runs: Int
    var rbis: Int
    var doubles: Int
    var triples: Int
    var homeRuns: Int
    var strikeouts: Int
    var walks: Int
    var stolenBases: Int
    
    var average: Double {
        let average = Double(hits) / Double(atBats)
        if average.isNaN  || average.isInfinite {
            return 0.0
        }
        return average
    }
    
    init() {
        opponent = ""
        date = ""
        atBats = 0
        hits = 0
        runs = 0
        rbis = 0
        doubles = 0
        triples = 0
        homeRuns = 0
        stolenBases = 0
        strikeouts = 0
        walks = 0
    }
}
