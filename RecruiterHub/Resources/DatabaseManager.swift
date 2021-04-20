//
//  DatabaseManager.swift
//  Instagram
//
//  Created by Ryan Helgeson on 11/25/20.
//

import Foundation
import FirebaseDatabase
import AVFoundation
import MessageKit

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
    
    public func like(with email: String, likerInfo: PostLike, postNumber: Int, completion: @escaping () -> Void ) {
        print("Like")
        
        let ref = database.child("\(email.safeDatabaseKey())/Posts/\(postNumber)/likes")
        
        ref.observeSingleEvent(of: .value, with: {snapshot in
        
            let element = [
                "email": likerInfo.email,
                "name": likerInfo.name,
                "username": likerInfo.username
            ]
            // No likes
            guard var likes = snapshot.value as? [[String:String]] else {
                print("Not type of postlike")
                ref.setValue([element])
                completion()
                return
            }
            
            // Person already liked, delete their like
            if likes.contains(element) {
                print("Already liked")
                if let index = likes.firstIndex(of: element) {
                    likes.remove(at: index)
                    ref.setValue(likes)
                }
                completion()
                return
            }
            
            // Add new like
            let newElement = element
            likes.append(newElement)
            ref.setValue(likes)
            completion()
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
    
    // TODO: Do this function 
    public func getUserEndorsements( email: String, completion: @escaping (([[String:String]]?) -> Void))  {
        database.child("\(email)/endorsements").observeSingleEvent(of: .value, with: { snapshot in
            let dictionary = ["email": "myemail@gmail.com"]
            dictionary["email"] // "myemail@gmail.com"
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
    
    public func sendMessage( to conversation: String, otherUserEmail: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        //add new messag to messages
        // update sender latest message
        // update recipient latest message
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let currentEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
            guard var currentMessages = snapshot.value as? [[String:Any]] else {
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .video(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .location(let locationData):
                let location = locationData.location
                message = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(let mediaItem):
                if let media = mediaItem as? MediaItem {
                    if let targetUrlString = media.url?.absoluteString {
                        message = targetUrlString
                    }
                }
                break
            }
            
            guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            
            let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "is_read": false,
                "name": name
            ]
            
            currentMessages.append(newMessageEntry)
            
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(currentEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    var databaseEntryConversations = [[String: Any]]()
                    let updatedValue:[String:Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]
                    if var currentUserConversations = snapshot.value as? [[String: Any]] {
                        // we need to create conversation entry
                        var targetConversation: [String:Any]?
                        
                        var position = 0
                        
                        for conversationDictionary in currentUserConversations {
                            if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                targetConversation = conversationDictionary
                                break
                            }
                            position += 1
                        }
                        
                        if var targetConversation = targetConversation {
                            targetConversation["latest_message"] = updatedValue
                            currentUserConversations[position] = targetConversation
                            databaseEntryConversations = currentUserConversations
                        }
                        else {
                            let newConversationData: [String: Any] = [
                                "id": conversation,
                                "other_user_email": DatabaseManager.safeEmail(emailAddress: otherUserEmail),
                                "name": name,
                                "latest_message": updatedValue
                            ]
                            currentUserConversations.append(newConversationData)
                            databaseEntryConversations = currentUserConversations
                        }
                    }
                    else {
                        let newConversationData: [String: Any] = [
                            "id": conversation,
                            "other_user_email": DatabaseManager.safeEmail(emailAddress: otherUserEmail),
                            "name": name,
                            "latest_message": updatedValue
                        ]
                        databaseEntryConversations = [
                            newConversationData
                        ]
                    }
                   
                    strongSelf.database.child("\(currentEmail)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        
                        // update latest message for recipient
                        
                        strongSelf.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            
                            var databaseEntryConversations = [[String: Any]]()
                            let updatedValue:[String:Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message": message
                            ]

                            guard let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
                                return
                            }

                            if var otherUserConversations = snapshot.value as? [[String: Any]] {
                                var targetConversation: [String:Any]?
                                
                                var position = 0
                                
                                for conversationDictionary in otherUserConversations {
                                    if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                        targetConversation = conversationDictionary
                                        break
                                    }
                                    position += 1
                                }
                                
                                if var targetConversation = targetConversation {
                                    targetConversation["latest_message"] = updatedValue
                                    otherUserConversations[position] = targetConversation
                                    databaseEntryConversations = otherUserConversations
                                }
                                else {
                                    // Failed to find the target conversation
                                    let newConversationData: [String: Any] = [
                                        "id": conversation,
                                        "other_user_email": DatabaseManager.safeEmail(emailAddress: currentEmail),
                                        "name": currentName,
                                        "latest_message": updatedValue
                                    ]
                                    otherUserConversations.append(newConversationData)
                                    databaseEntryConversations = otherUserConversations
                                }
                            
                            }
                            else {
                                let newConversationData: [String: Any] = [
                                    "id": conversation,
                                    "other_user_email": DatabaseManager.safeEmail(emailAddress: currentEmail),
                                    "name": currentName,
                                    "latest_message": updatedValue
                                ]
                                databaseEntryConversations = [
                                    newConversationData
                                ]
                            }
                            
                           strongSelf.database.child("\(otherUserEmail)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                
                                completion(true)
                            })
                        })
                    })
                })
            })
        })
    }
    
    // Creates a new conversation with target user email and first message sent
    public func createNewConversation( with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void ) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
            let currentName = UserDefaults.standard.value(forKey: "name") else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        
        let ref = database.child(safeEmail)
        
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("User not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
                
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationID = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String: Any] = [
                "id": conversationID,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            let recipient_newConversationData: [String: Any] = [
                "id": conversationID,
                "other_user_email": safeEmail,
                "name": currentName,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            // Update recipient conversation entry
            
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    // append
                    conversations.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversationID)
                }
                else {
                    //create
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
            })

            if var conversations = userNode["conversations"] as? [[String: Any]] {
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }

                    self?.finishCreatingConversation( name: name, conversationID: conversationID, firstMessage: firstMessage, completion: completion)

                }
            }
            else {
                // Conversation array does not exist
                // Create it
                userNode["conversations"] = [
                    newConversationData
                ]

                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }

                    self?.finishCreatingConversation( name: name, conversationID: conversationID, firstMessage: firstMessage, completion: completion)

                })
            }
        })
    }
    
    // Fetches and returns all conversations for the user with passed in email
    public func getAllConversations( for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void ) {
        database.child("\(email)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                    let name = dictionary["name"] as? String,
                    let otherUserEmail = dictionary["other_user_email"] as? String,
                    let latestMessage = dictionary["latest_message"] as? [String: Any],
                    let date = latestMessage["date"] as? String,
                    let message = latestMessage["message"] as? String,
                    let isRead = latestMessage["is_read"] as? Bool else {
                        return nil
                }

                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                
                return Conversation( id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
                
            })
            
            completion(.success(conversations))
        })
    }
    
    private func finishCreatingConversation( name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind {
            
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name": name
        ]
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        database.child("\(conversationID)").setValue(value, withCompletionBlock: {error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            
            completion(true)
        })
    }
    
    public func conversationExists(with targetRecipientEmail: String, completion: @escaping (Result<String, Error>) -> Void) {
        let safeRecipientEmail = DatabaseManager.safeEmail(emailAddress: targetRecipientEmail)
        guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeSenderEmail = DatabaseManager.safeEmail(emailAddress: senderEmail)
        
        database.child("\(safeRecipientEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
            guard let collection = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            if let conversation = collection.first(where: {
                guard let targetSenderEmail = $0["other_user_email"] as? String else {
                    return false
                }
                return safeSenderEmail == targetSenderEmail
            }) {
                //Get id
                guard let id = conversation["id"] as? String else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                
                completion(.success(id))
                return
            }
            
            completion(.failure(DatabaseError.failedToFetch))
            return
        })
    }
    
    public func deleteConversation(conversationId: String, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        print("Deleting the conversation with id: \(conversationId)")
        // Get all conversations for current User
        //Delete convesation with target id
        // Reset those conversations for use in database
        let ref = database.child("\(safeEmail)/conversations")
        ref.observeSingleEvent(of: .value) { snapshot in
            if var conversations = snapshot.value as? [[String: Any]] {
                var positionToRemove = 0
                for conversation in conversations {
                    if let id = conversation["id"] as? String,
                       id == conversationId {
                        print("Found conversation to delete")
                        break
                    }
                    positionToRemove += 1
                }
                
                conversations.remove(at: positionToRemove)
                ref.setValue(conversations, withCompletionBlock: { error,_ in
                    guard error == nil else {
                        completion(false)
                        print("Failed to write new conversation array")
                        return
                    }
                    print("Deleted Conversation")
                    completion(true)
                })
            }
        }
    }
    
    // Get all messages for a given conversation
    public func getAllMessagesForConversations( for id: String, completion: @escaping (Result<[Message], Error>) -> Void ) {
        database.child("\(id)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap({ dictionary in
                guard let name = dictionary["name"] as? String,
                      //let isRead = dictionary["is_read"] as? Bool,
                      let messageId = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let date = ChatViewController.dateFormatter.date(from: dateString) else {
                    return nil
                }
                
                var kind: MessageKind?
                if type == "photo" {
                    // Photo
                    guard let imageUrl = URL(string: content),
                          let placeHolder = UIImage(systemName: "plus") else {
                        return nil
                    }
                    
                    let media = Media(url: imageUrl, image: nil, placeholderImage: placeHolder, size: CGSize(width: 300, height: 300))
                    
                    kind = .photo(media)
                    
                }
                else if type == "video"  {
                    // Photo
                    guard let videoUrl = URL(string: content),
                          let placeHolder = UIImage(systemName: "plus") else {
                        return nil
                    }
                    
                    let media = Media(url: videoUrl, image: nil, placeholderImage: placeHolder, size: CGSize(width: 300, height: 300))
                    
                    kind = .video(media)
                }
                else if type == "location" {
//                    let locationComponents = content.components(separatedBy: ",")
//                    guard let longitude = Double(locationComponents[0]),
//                          let latitude = Double(locationComponents[1]) else {
//                        return nil
//                    }
//
//                    let location = Location(location: CLLocation(latitude: latitude, longitude: longitude), size: CGSize(width: 300, height: 300))
//
//                    kind = .location(location)
                }
                else {
                    kind = .text(content)
                }
                
                guard let finalKind = kind else {
                    return nil
                }
                
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                
                return Message(sender: sender, messageId: messageId, sentDate: date, kind: finalKind)
            })
            
            completion(.success(messages))
        })
    }
    
    public func getPitcherGameLogsForUser(user: String, completion: @escaping (([PitcherGameLog]?) -> Void)) {
        database.child("\(user)/PitcherGameLogs").observeSingleEvent(of: .value, with:  { snapshot in
            
            guard let pitcherGameLogsDictionary = snapshot.value as? [[String: Any]] else {
                completion(nil)
                return
            }
            var pitcherGameLogs: [PitcherGameLog] = []
            
            for log in pitcherGameLogsDictionary {
                guard let date = log["date"] as? String,
                      let opponent =  log["opponent"] as? String,
                      let inningsPitched = log["inningsPitched"] as? Double,
                      let hits =  log["hits"] as? Int,
                      let runs =  log["runs"] as? Int,
                      let earnedRuns = log["earnedRuns"] as? Int,
                      let strikeouts = log["strikeouts"] as? Int,
                      let walks = log["walks"] as? Int else {
                   print("Failed to get user data")
                    completion(nil)
                    return
                }
                var pitcherGameLog = PitcherGameLog()
                pitcherGameLog.date = date
                pitcherGameLog.opponent = opponent
                pitcherGameLog.inningsPitched = inningsPitched
                pitcherGameLog.hits = hits
                pitcherGameLog.runs = runs
                pitcherGameLog.earnedRuns = earnedRuns
                pitcherGameLog.strikeouts = strikeouts
                pitcherGameLog.walks = walks
                pitcherGameLogs.append(pitcherGameLog)
            }
            
            completion(pitcherGameLogs)
        })
    }
    
    public func getBatterGameLogsForUser(user: String, completion: @escaping (([BatterGameLog]?) -> Void)) {
        database.child("\(user)/BatterGameLogs").observeSingleEvent(of: .value, with:  { snapshot in
            
            guard let batterGameLogsDictionary = snapshot.value as? [[String: Any]] else {
                completion(nil)
                return
            }
            var batterGameLogs: [BatterGameLog] = []
            
            for log in batterGameLogsDictionary {
                guard let date = log["date"] as? String,
                      let opponent =  log["opponent"] as? String,
                      let atBats = log["atBats"] as? Int,
                      let hits =  log["hits"] as? Int,
                      let runs =  log["runs"] as? Int,
                      let rbis =  log["rbis"] as? Int,
                      let doubles = log["doubles"] as? Int,
                      let triples = log["triples"] as? Int,
                      let homeruns = log["homeruns"] as? Int,
                      let strikeouts = log["strikeouts"] as? Int,
                      let walks = log["walks"] as? Int,
                      let stolenBases = log["stolenBases"] as? Int else {
                   print("Failed to get user data")
                    completion(nil)
                    return
                }
                var batterGameLog = BatterGameLog()
                batterGameLog.date = date
                batterGameLog.opponent = opponent
                batterGameLog.atBats = atBats
                batterGameLog.hits = hits
                batterGameLog.runs = runs
                batterGameLog.rbis = rbis
                batterGameLog.doubles = doubles
                batterGameLog.triples = triples
                batterGameLog.homeRuns = homeruns
                batterGameLog.strikeouts = strikeouts
                batterGameLog.walks = walks
                batterGameLog.stolenBases = stolenBases
                
                batterGameLogs.append(batterGameLog)
            }
            
            completion(batterGameLogs)
        })
    }
    
    public func addGameLogForUser( email: String, gameLog: PitcherGameLog) {
        database.child("\(email)/PitcherGameLogs").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            let newElement: [String:Any] = [
                "date": gameLog.date,
                "opponent": gameLog.opponent,
                "inningsPitched": gameLog.inningsPitched,
                "hits": gameLog.hits,
                "runs": gameLog.runs,
                "earnedRuns": gameLog.earnedRuns,
                "strikeouts": gameLog.strikeouts,
                "walks": gameLog.walks
            ]
            
            if var gameLogs = snapshot.value as? [[String: Any]] {
                print("Collection Exists")
                gameLogs.append(newElement)
                
                self?.database.child("\(email)/PitcherGameLogs").setValue(gameLogs, withCompletionBlock:  { error, _ in
                    guard error == nil else {
                        return
                    }
                })
            }
            else {
                print("New Collection")
                let newCollection: [[String: Any]] = [newElement]
                
                self?.database.child("\(email)/PitcherGameLogs").setValue(newCollection, withCompletionBlock:  { error, _ in
                    guard error == nil else {
                        return
                    }
                })
            }
       })
    }
    
    public func addBatterGameLogForUser( email: String, gameLog: BatterGameLog) {
        database.child("\(email)/BatterGameLogs").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            let newElement: [String:Any] = [
                "date": gameLog.date,
                "opponent": gameLog.opponent,
                "atBats": gameLog.atBats,
                "hits": gameLog.hits,
                "runs": gameLog.runs,
                "rbis": gameLog.rbis,
                "doubles": gameLog.doubles,
                "triples": gameLog.triples,
                "homeruns": gameLog.homeRuns,
                "strikeouts": gameLog.strikeouts,
                "walks": gameLog.walks,
                "stolenBases": gameLog.stolenBases
            ]
            
            if var gameLogs = snapshot.value as? [[String: Any]] {
                print("Collection Exists")
                gameLogs.append(newElement)
                
                self?.database.child("\(email)/BatterGameLogs").setValue(gameLogs, withCompletionBlock:  { error, _ in
                    guard error == nil else {
                        return
                    }
                })
            }
            else {
                print("New Collection")
                let newCollection: [[String: Any]] = [newElement]
                
                self?.database.child("\(email)/BatterGameLogs").setValue(newCollection, withCompletionBlock:  { error, _ in
                    guard error == nil else {
                        return
                    }
                })
            }
       })
    }
}

