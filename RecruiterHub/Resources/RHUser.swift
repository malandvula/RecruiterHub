//
//  RHUser.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/15/21.
//

import Foundation

public struct RHUser {
    var username: String
    var firstName: String
    var lastName: String
    var emailAddress:String
    var phone: String
    var gpa: Double
//    var fastball: Pitch
//    var breakingBall: Pitch
//    var change: Pitch
    var positions: [String]
    var highShcool: String?
    var state: String?
    var gradYear: Int?
    var heightFeet: Int?
    var heightInches: Int?
    var weight: Int?
    var arm: String?
    var bats: String?
    var profilePicUrl: String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    var name: String {
        let name = firstName + " " + lastName
        return name
    }
    
    var profilePictureFileName: String {
        //"ryanhelgeson14-gmail-com_profile_picture.png"
        return "\(safeEmail)_profile_picture.png"
    }
    
    init() {
        username = ""
        firstName = ""
        lastName = ""
        emailAddress = ""
        phone = ""
        gpa = 0.0
//          ar fastball: Pitch
        //  ar breakingBall: Pitch
        //  ar change: Pitch
        positions = []
        highShcool = ""
        state = ""
        gradYear = 0
        heightFeet = 0
        heightInches = 0
        weight = 0
        arm = ""
        bats = ""
        profilePicUrl = ""
    }
}



struct Pitch {
    let topVelocity: Double
    let vertBreak: Double
    let horizBreak: Double
}
