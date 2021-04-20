//
//  Keyboard.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 3/4/21.
//

import SwiftUI

public class Keyboard {
    public static func keyboardWillShow(vc: UIViewController, notification: NSNotification ) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if  notification.name == UIResponder.keyboardWillShowNotification {
                if vc.view.frame.origin.y == 0 {
                    vc.view.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }
    
    public static func keyboardWillHide(vc: UIViewController) {
        if vc.view.frame.origin.y != 0 {
            vc.view.frame.origin.y = 0
        }
    }
}
