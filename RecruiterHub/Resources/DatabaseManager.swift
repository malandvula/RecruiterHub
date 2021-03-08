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
    
    static func findPost( posts: [[String: Any]], url: String) -> Int {
        
        var index = 0
        for post in posts {
            guard let postUrl = post["url"] as? String else {
                return posts.count
            }
            
            if postUrl == url {
                print("Found url")
                break
            }
            else {
                index += 1
            }
        }
        
        return index
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
        database.child(email.safeDatabaseKey()).child("phone").setValue(user.phone)

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
                print("Failure")
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
    
    public func insertNewPost(with email: String, url: Upload, caption: String) {
        database.child("\(email)/Posts").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            var comment: String
            if caption == "" {
                comment = ""
            }
            else {
                comment = caption
            }
            
            var comments: [[String:String]] = []
            comments.append([
                "email": email,
                "comment": comment
            ])
            
            let newElement: [String : Any] = [
                "url": url.videoUrl,
                "thumbnail": url.thumbnailUrl,
                "likes": "",
                "comments": comments
            ]
            
            if var usersCollection = snapshot.value as? [[String: Any]] {
                print("Collection Exists")
                usersCollection.append(newElement)
                
                self?.database.child("\(email)/Posts").setValue(usersCollection, withCompletionBlock:  { error, _ in
                    guard error == nil else {
                        return
                    }
                })
            }
            else {
                print("New Collection")
                let newCollection: [[String: Any]] = [newElement]
                
                self?.database.child("\(email)/Posts").setValue(newCollection, withCompletionBlock:  { error, _ in
                    guard error == nil else {
                        return
                    }
                })
            }
            self?.insertFeedPost(email: email, url: url.videoUrl)
            
        })
    }
    
    private func insertFeedPost(email: String, url: String) {
        database.child("FeedPosts").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            if var feedCollection = snapshot.value as? [[String: String]] {
                
                let newElement = [
                    "email": email,
                    "url": url
                ]
                feedCollection.append(newElement)
                
                self?.database.child("FeedPosts").setValue(feedCollection, withCompletionBlock:  { error, _ in
                    guard error == nil else {
                        return
                    }
                })
            }
            else {
                let newCollection: [[String: String]] = [
                    [
                        "email": email,
                        "url": url
                    ]
                ]
                
                self?.database.child("FeedPosts").setValue(newCollection, withCompletionBlock:  { error, _ in
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
                  let phone = info["phone"] as? String,
                  let profilePicUrl = info["profilePicUrl"] as? String else {
               print("Failed to get user data")
                completion(nil)
                return
            }
            var userData = RHUser()
            userData.username = username
            userData.firstName = firstname
            userData.lastName = lastname
            userData.emailAddress = user
            userData.phone = phone
            userData.gpa = 0
            userData.positions = ["RHP", "OF"]
            userData.highShcool = highSchool
            userData.state = state
            userData.gradYear = gradYear
            userData.heightFeet = heightFeet
            userData.heightInches = heightInches
            userData.weight = weight
            userData.arm = arm
            userData.bats = bats
            userData.profilePicUrl = profilePicUrl
            
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
    }
    
    public func setProfilePic(with email: String, url: String) {
        database.child("\(email.safeDatabaseKey())/profilePicUrl").setValue(url)
    }
    
    public func getFeedPosts(completion: @escaping (([[String:String]]?) -> Void))  {
        database.child("FeedPosts").observeSingleEvent(of: .value, with: { snapshot in
            guard let feedPosts = snapshot.value as? [[String:String]] else {
                completion(nil)
                return
            }
            
            completion(feedPosts)
        })
    }
    
    public func newGetFeedPosts(completion: @escaping (([FeedPost]?) -> Void))  {
        database.child("FeedPosts").observeSingleEvent(of: .value, with: { snapshot in
            guard let feedPosts = snapshot.value as? [[String:String]] else {
                completion(nil)
                return
            }
            var array = [FeedPost]()
            for post in feedPosts {
                
                guard let email = post["email"] else {
                    return
                }
                
                guard let urlString = post["url"],
                      let url = URL(string: urlString) else {
                    print("Url Failed")
                    return
                }

                let asset = AVAsset(url: url)
                let playerItem = AVPlayerItem(asset: asset)
                let player = AVPlayer(playerItem: playerItem)
                
                
                let temp = FeedPost(email: email, url: player, image: "")
                
                array.append(temp)
                
                
            }
            
            completion(array)
        })
    }
    
    public func getUserFollowers( email: String, completion: @escaping (([[String:String]]?) -> Void))  {
        
        database.child("\(email)/followers").observeSingleEvent(of: .value, with: { snapshot in
            guard let feedPosts = snapshot.value as? [[String:String]] else {
                completion(nil)
                return
            }
        
            completion(feedPosts)
        })
    }
    
    public func getUserFollowing( email: String, completion: @escaping (([[String:String]]?) -> Void))  {
        
        database.child("\(email)/following").observeSingleEvent(of: .value, with: { snapshot in
            guard let feedPosts = snapshot.value as? [[String:String]] else {
                completion(nil)
                return
            }
        
            completion(feedPosts)
        })
    }
    
    public func updateUserInfor( user: RHUser) {
        let email = user.emailAddress.safeDatabaseKey()
        
        database.child(email).child("username").setValue(user.username)
        database.child(email).child("firstname").setValue(user.firstName)
        database.child(email).child("lastname").setValue(user.lastName)
        database.child(email).child("positions").setValue(user.positions)
        database.child(email).child("heightFeet").setValue(user.heightFeet)
        database.child(email).child("heightInches").setValue(user.heightInches)
        database.child(email).child("highschool").setValue(user.highShcool)
        database.child(email).child("state").setValue(user.state)
        database.child(email).child("weight").setValue(user.weight)
        database.child(email).child("arm").setValue(user.arm)
        database.child(email).child("bats").setValue(user.bats)
        database.child(email).child("gradYear").setValue(user.gradYear)
    }
    
    public func follow( email: String, followerEmail: String) {
        print("Follow")
        
        let refFollower = database.child("\(email.safeDatabaseKey())/followers")
        
        refFollower.observeSingleEvent(of: .value, with: { snapshot in
        
            let element = [
                "email": followerEmail
            ]
            // No followers
            guard var likes = snapshot.value as? [[String:String]] else {
                refFollower.setValue([element])
                return
            }
            
            // Person already liked, delete their like
            if likes.contains(element) {
                print("Already followed")
                if let index = likes.firstIndex(of: element) {
                    likes.remove(at: index)
                    refFollower.setValue(likes)
                }
                return
            }
            
            // Add new like
            let newElement = element
            likes.append(newElement)
            refFollower.setValue(likes)
        })
        
        let refCurrentUser = database.child("\(followerEmail.safeDatabaseKey())/following")
        
        refCurrentUser.observeSingleEvent(of: .value, with: { snapshot in
        
            let element = [
                "email": email
            ]
            // No followers
            guard var likes = snapshot.value as? [[String:String]] else {
                refCurrentUser.setValue([element])
                return
            }
            
            // Person already liked, delete their like
            if likes.contains(element) {
                print("Already followed")
                if let index = likes.firstIndex(of: element) {
                    likes.remove(at: index)
                    refCurrentUser.setValue(likes)
                }
                return
            }
            
            // Add new like
            let newElement = element
            likes.append(newElement)
            refCurrentUser.setValue(likes)
        })
    }
    
    public func getComments(with email: String, index: Int, completion: @escaping (([[String:String]]?) -> Void)) {
        database.child("\(email)/Posts/\(index)/comments").observeSingleEvent(of: .value, with: { snapshot in
            
            guard let comments = snapshot.value as? [[String:String]] else {
                print("Failed to get comments")
                completion(nil)
                return
            }

            completion(comments)
        })
        completion(nil)
    }
    
    public func getLikes(with email: String, index: Int, completion: @escaping (([[String:String]]?) -> Void)) {
        database.child("\(email)/Posts/\(index)/likes").observeSingleEvent(of: .value, with: { snapshot in
            
            guard let likes = snapshot.value as? [[String:String]] else {
                print("Failed to get likes")
                completion(nil)
                return
            }

            completion(likes)
        })
        completion(nil)
    }
    
    public func newComment( email: String, commenterEmail: String, comment: String, index: Int) {
        database.child("\(email)/Posts/\(index)/comments").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            guard var comments = snapshot.value as? [[String:String]] else {
                print("Failed to get comments")
                return
            }
            
            let newElement = [
                "email": commenterEmail,
                "comment": comment
            ]
            
            comments.append(newElement)
            
            self?.database.child("\(email)/Posts/\(index)/comments").setValue(comments)
        })
    }
    
    public func getScoutInfoForUser(user: String, completion: @escaping ((ScoutInfo?) -> Void)) {
        database.child("\(user)/scoutInfo").observeSingleEvent(of: .value, with:  { snapshot in
            
            guard let info = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            
            guard let fastball = info["fastball"] as? Double,
                  let curveball =  info["curveball"] as? Double,
                  let slider = info["slider"] as? Double,
                  let changeup =  info["changeup"] as? Double,
                  let sixty =  info["sixty"] as? Double,
                  let infield = info["infield"] as? Double,
                  let outfield = info["outfield"] as? Double,
                  let exitVelo = info["exitVelo"] as? Double else {
               print("Failed to get user data")
                completion(nil)
                return
            }
            var scoutInfo = ScoutInfo()
            scoutInfo.fastball = fastball
            scoutInfo.curveball = curveball
            scoutInfo.slider = slider
            scoutInfo.changeup = changeup
            scoutInfo.sixty = sixty
            scoutInfo.infield = infield
            scoutInfo.outfield = outfield
            scoutInfo.exitVelo = exitVelo
    
            completion(scoutInfo)
        })
    }
    
    public func updateScoutInfoForUser(email: String, scoutInfo: ScoutInfo) {
        database.child("\(email)/scoutInfo").child("fastball").setValue(scoutInfo.fastball)
        database.child("\(email)/scoutInfo").child("curveball").setValue(scoutInfo.curveball)
        database.child("\(email)/scoutInfo").child("slider").setValue(scoutInfo.slider)
        database.child("\(email)/scoutInfo").child("changeup").setValue(scoutInfo.changeup)
        database.child("\(email)/scoutInfo").child("sixty").setValue(scoutInfo.sixty)
        database.child("\(email)/scoutInfo").child("infield").setValue(scoutInfo.infield)
        database.child("\(email)/scoutInfo").child("outfield").setValue(scoutInfo.outfield)
        database.child("\(email)/scoutInfo").child("exitVelo").setValue(scoutInfo.exitVelo)
    }
    
    public func getNumberOf( email: String, connection: Connections, completion: @escaping (Int) -> Void) {
        var attribute = ""
        switch connection {
        case .follower:
            attribute = "followers"
            break
        case .following:
            attribute = "following"
            break
        case .endorsers:
            attribute = "endorsers"
            break
        }
        database.child("\(email)/\(attribute)").observeSingleEvent(of: .value, with: {
            snapshot in
            
            guard let list = snapshot.value as? [[String: String]] else {
                completion(0)
                return
            }
            completion(list.count)
        })
    }
}
