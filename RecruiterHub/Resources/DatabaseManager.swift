//
//  DatabaseManager.swift
//  Instagram
//
//  Created by Ryan Helgeson on 11/25/20.
//

import Foundation
import FirebaseDatabase
import AVFoundation

public class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    static func createThumbnail(url: URL) -> UIImage {
        let asset = AVURLAsset(url: url, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 1), actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            return  uiImage
        }
        catch {
            return UIImage(systemName: "person.circle")!
        }
        
    }
    
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        print("Checking if user exists")
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? [String: String] != nil else {
                print("User doesn't exist")
                completion(false)
                return
            }
            print("User exists")
            completion(true)
        })
    }
    
    //MARK: - Public
    
    ///Check if username and email is available
    /// -Parameters
    ///     -email: String representing email
    //      -username: string represting email
    public func canCreateNewUser(with email: String, username: String, completion: (Bool) -> Void) {
        completion(true)
    }
    

    /*
     //Inserts new user data to database
     // -Parameters
     //     -email: String representing email
     //         -username: string represting email
     */
    public func insertNewUser(with email: String, user: RHUser, completion: @escaping (Bool) -> Void) {
        database.child(email.safeDatabaseKey()).child("username").setValue(user.username)
        database.child(email.safeDatabaseKey()).child("firstname").setValue(user.firstName)
        database.child(email.safeDatabaseKey()).child("lastname").setValue(user.lastName)
        database.child(email.safeDatabaseKey()).child("positions").setValue(user.positions)
        database.child(email.safeDatabaseKey()).child("heightFeet").setValue(user.heightFeet)
        database.child(email.safeDatabaseKey()).child("heightInches").setValue(user.heightInches)
        database.child(email.safeDatabaseKey()).child("highschool").setValue(user.highShcool)
        database.child(email.safeDatabaseKey()).child("state").setValue(user.state)
        database.child(email.safeDatabaseKey()).child("weight").setValue(user.weight)
        database.child(email.safeDatabaseKey()).child("arm").setValue(user.arm)
        database.child(email.safeDatabaseKey()).child("bats").setValue(user.bats)
        database.child(email.safeDatabaseKey()).child("gradYear").setValue(user.gradYear)

        database.child("users").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            if var usersCollection = snapshot.value as? [[String: String]] {
                
                let newElement = [
                    "name": "\(user.firstName) \(user.lastName)",
                    "email": user.emailAddress.safeDatabaseKey(),
                    "username": "\(user.username)"
                ]
                print("appending new user")
                usersCollection.append(newElement)
                
                self?.database.child("users").setValue(usersCollection, withCompletionBlock:  { error, _ in
                    guard error == nil else {
                        return
                    }
                })
            }
            else {
                let newCollection: [[String: String]] = [
                    [
                        "name": "\(user.firstName) \(user.lastName)",
                        "email": "\(user.emailAddress)",
                        "username": "\(user.username)"
                    ]
                ]
                
                self?.database.child("users").setValue(newCollection, withCompletionBlock:  { error, _ in
                    guard error == nil else {
                        return
                    }
                })
            }
        })
        
        completion(true)
    }
    
    /// Gets all users from a database
    public func getAllUsers( completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            print(snapshot)
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }

    public enum DatabaseError: Error {
        case failedToFetch
        
        public var localizedDescription: String {
            switch self {
            case .failedToFetch:
                return "Fetch failed"
            }
        }
    }
    
    public func insertNewPost(with email: String, url: Upload) {
        database.child("\(email)/Posts").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            if var usersCollection = snapshot.value as? [[String: String]] {
                
                let newElement = [
                    "url": url.videoUrl,
                    "thumbnail": url.thumbnailUrl,
                    "likes": ""
                ]
                usersCollection.append(newElement)
                
                self?.database.child("\(email)/Posts").setValue(usersCollection, withCompletionBlock:  { error, _ in
                    guard error == nil else {
                        return
                    }
                })
            }
            else {
                let newCollection: [[String: String]] = [
                    [
                        "url": url.videoUrl,
                        "thumbnail": url.thumbnailUrl,
                        "likes": ""
                    ]
                ]
                
                self?.database.child("\(email)/Posts").setValue(newCollection, withCompletionBlock:  { error, _ in
                    guard error == nil else {
                        return
                    }
                })
            }
        })
    }
    
    public func getVideo(completion: @escaping ((String?) -> Void) ) {
        database.child("Test/Posts").observeSingleEvent(of: .value, with: { snapshot in
            guard let posts = snapshot.value as! [[String:String]]? else {
                completion(nil)
                return
            }
            let url = posts[0]["url"]
            completion(url)
        })
    }
    
    public func getAllUserPosts(with email: String, completion: @escaping (([[String:Any]]?) -> Void)) {
        database.child("\(email)/Posts").observeSingleEvent(of: .value, with: { snapshot in

            guard let posts = snapshot.value as? [[String:Any]] else {
                print("Failed to get all user posts")
                completion(nil)
                return
            }

            completion(posts)
        })
        completion(nil)
    }
    
    public func getDataForUser(user: String, completion: @escaping ((RHUser?) -> Void)) {
        database.child(user).observeSingleEvent(of: .value, with:  { snapshot in
            
            guard let info = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            
            guard let username = info["username"] as? String,
                  let heightInches =  info["heightInches"] as? Int,
                  let heightFeet = info["heightFeet"] as? Int,
                  let weight =  info["weight"] as? Int,
                  let gradYear =  info["gradYear"] as? Int,
                  let state = info["state"] as? String,
                  let highSchool = info["highschool"] as? String,
//                  let positions = info["positions"] as? [String:String],
                  let arm = info["arm"] as? String,
                  let bats = info["bats"] as? String,
                  let lastname = info["lastname"] as? String,
                  let firstname = info["firstname"] as? String,
                  let profilePicUrl = info["profilePicUrl"] as? String else {
               print("Failed to get user data")
                completion(nil)
                return
            }
            let userData = RHUser(username: username,
                              firstName: firstname,
                              lastName: lastname,
                              emailAddress: user,
                              positions: ["RHP", "OF"],
                              highShcool: highSchool,
                              state: state,
                              gradYear: gradYear,
                              heightFeet: heightFeet,
                              heightInches: heightInches,
                              weight: weight,
                              arm: arm,
                              bats: bats,
                              profilePicUrl: profilePicUrl)
            completion(userData)
        })
    }
    
    public func like(with email: String, likerInfo: PostLike, postNumber: Int) {
        print("Like")
        
        let ref = database.child("\(email.safeDatabaseKey())/Posts/\(postNumber)/likes")
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
        
            let element = [
                "email": likerInfo.email,
                "name": likerInfo.name,
                "username": likerInfo.username
            ]
            // No likes
            print(snapshot.value)
            guard var likes = snapshot.value as? [[String:String]] else {
                print("Not type of postlike")
                ref.setValue([element])
                return
            }
            
            // Person already liked, delete their like
            if likes.contains(element) {
                print("Already liked")
                if let index = likes.firstIndex(of: element) {
                    likes.remove(at: index)
                    ref.setValue(likes)
                }
                return
            }
            
            // Add new like
            let newElement = element
            likes.append(newElement)
            ref.setValue(likes)
        })
        
//        database.child("\(email.safeDatabaseKey())/Posts/\(postNumber)").setValue(["\(email)"], withCompletionBlock: { result , error  in
//            print(error)
//        })
    }
    
    public func setProfilePic(with email: String, url: String) {
        database.child("\(email.safeDatabaseKey())/profilePicUrl").setValue(url)
    }
}
