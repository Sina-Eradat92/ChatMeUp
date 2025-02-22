//
//  DataBaseManager.swift
//  ChatMeUp
//
//  Created by Sina Eradat on 2/17/25.
//

import Foundation
import FirebaseDatabase

final class DataBaseManager {
    
    static let shared = DataBaseManager()
    
    private let database = Database.database().reference()
    
    private init() {}
    
    
    /// Check if a user already exists in the database
    /// - Parameter email: The email associated with a given user
    func userExists(for user: ChatAppUser) async -> Bool {
        return await withCheckedContinuation { continuation in
            database.child(user.safeEmail).observeSingleEvent(of: .value) { snapshot in
                guard (try? snapshot.data(as: ChatAppUser.self)) != nil else { continuation.resume(returning: false); return }
                continuation.resume(returning: true)
            }
        }
    }
    
    func userExists(with email: String) async -> Bool {
        let safeEmail = email.replacingOccurrences(of: ".", with: "-").replacingOccurrences(of: "@", with: "-")
        return await withCheckedContinuation { continuation in
            database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
                guard (try? snapshot.data(as: ChatAppUser.self)) != nil else { continuation.resume(returning: false); return }
                continuation.resume(returning: true)
            }
        }
    }
    
    
    /// Insert a user into the database
    /// - Parameter user: A chat app user object
    func insertUser(with user: ChatAppUser) throws {
        try database.child(user.safeEmail).setValue(from: user)
    }
}

struct ChatAppUser: Codable {
    let first_name: String
    let last_name: String
    let email_address: String
//    let profilePictureUrl: String
    
    var safeEmail: String {
        return email_address.replacingOccurrences(of: ".", with: "-").replacingOccurrences(of: "@", with: "-")
    }
}
