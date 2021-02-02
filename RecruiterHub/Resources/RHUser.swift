//
//  RHUser.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/15/21.
//

import Foundation

public struct RHUser {
    let username: String
    let firstName: String
    let lastName: String
    let emailAddress:String
    let positions: [String]
    let highShcool: String?
    let state: String?
    let gradYear: Int?
    let heightFeet: Int?
    let heightInches: Int?
    let weight: Int?
    let arm: String?
    let bats: String?
    let profilePicUrl: String
    
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
}
