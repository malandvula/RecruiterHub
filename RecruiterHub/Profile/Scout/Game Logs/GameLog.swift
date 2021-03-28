//
//  File.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 3/27/21.
//

import Foundation

struct GameLog {
    var opponent: String
    var date: String
}

public struct PitcherGameLog {
    var opponent: String
    var date: String
    var inningsPitched: Int
    var hits: Int
    var runs: Int
    var earnedRuns: Int
    var strikeouts: Int
    var walks: Int
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
}
