//
//  Database.swift
//  obstacle_avoidance
//
//  Created by Austin Lim on 2/27/25.
//
// IMPORTANT!!!
// For next year's team, the database we're using is Supabase. That database closes down
// after 60 days of inactivity (I believe) You will need to make a new one and can be
// free, but the paid one might have more perks like no shutting down.
// The school will pay for it so don't worry about that. Creating the table is fairly
// easy, just make sure the table name is 'users' or you will run into errors. Every variable
// needs to be named exactly the same as written in struct and all of their types
// are listed next to them. You will also need to add RLS policies for select, insert, delete, and update.
// You will also store the key and URL in a local file called '.env', no .swift at the end, and place
// it in the root directory for this file to work. Also emergency
// contacts will not need its own table.

import Supabase
import Foundation

struct EnvLoader {
    static func loadEnv() -> [String: String] {
        let fileManager = FileManager.default

        // Try to get path dynamically from Bundle
        let possiblePaths = [
            Bundle.main.path(forResource: ".env", ofType: nil),
            FileManager.default.currentDirectoryPath + "/.env"
        ]

        let filePath = possiblePaths.compactMap { $0 }.first

        guard let path = filePath, fileManager.fileExists(atPath: path) else {
            print("Warning: .env file not found at \(filePath ?? "unknown path")!")
            return [:]
        }

        do {
            let contents = try String(contentsOfFile: path, encoding: .utf8)
            var envDict = [String: String]()

            for line in contents.split(separator: "\n") {
                let parts = line.split(separator: "=", maxSplits: 1).map { String($0) }
                if parts.count == 2 {
                    envDict[parts[0].trimmingCharacters(in: .whitespaces)] = parts[1].trimmingCharacters(in: .whitespaces)
                }
            }

            return envDict
        } catch {
            print("Error loading .env file: \(error)")
            return [:]
        }
    }
}
class Database {
    static let shared: Database = {
        return Database()
    }()

    private let client: SupabaseClient

    private init() {
        let env = EnvLoader.loadEnv()

        guard let supabaseURLString = env["SUPABASE_URL"],
              let supabaseKey = env["SUPABASE_KEY"],
              let supabaseURL = URL(string: supabaseURLString) else {
            fatalError("Missing or invalid Supabase credentials in .env file!")
        }

        self.client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }
}
extension Database {
    func addUser(name: String,
                 username: String,
                 password: String,
                 phoneNumber: String,
                 emergencyContacts: [EmergencyContact]?,
                 address: String,
                 email: String,
                 measurementType: String,
                 userHeight: Int,
                 hapticFeedback: Bool,
                 locationSharing: Bool) async {
        print("Adding user:", username)
        let salt = createSalt()
        let hashedPassword = hashSaltPassword(password: password, salt: salt)
        guard let jsonData = try? JSONEncoder().encode(emergencyContacts),
                  let jsonString = String(data: jsonData, encoding: .utf8) else {
                print("Failed to encode emergency contacts")
                return
        }
        do {
            let session = try await client.auth.signUp(email: email, password: password)
            let uid = session.user.id;
            
            let newUser = User(
                id: nil,
                name: name,
                username: username,
                phoneNumber: phoneNumber,
                emergencyContacts: emergencyContacts,
                createdAt: nil,
                hashedPassword: hashedPassword,
                saltedPassword: salt,
                address: address,
                email: email,
                userUid: uid,
                measurementType: measurementType,
                userHeight: userHeight,
                hapticFeedback: hapticFeedback,
                locationSharing: locationSharing
            )
            let response = try await client
                           .from("users")
                           .insert([newUser])
                           .execute()

            print("User added successfully:", response)
        } catch {
            print("Error adding user:", error)
        }
    }
    func updateUser(userId: Int,
                    newName: String?,
                    newUsername: String?,
                    newPhoneNumber: String?,
                    newEmail: String?,
                    newAddress: String?) async {
        
        var updateValues: [String: String] = [:]
        if let newUsername = newUsername {
            let existingUser = await checkIfExists(column: "username", value: newUsername, userId: userId)
            if existingUser {
                print("Error: Username is already taken.")
                return
            }
            updateValues["username"] = newUsername
        }

        if let newPhoneNumber = newPhoneNumber {
            let existingUser = await checkIfExists(column: "phone_number", value: newPhoneNumber, userId: userId)
            if existingUser {
                print("Error: Phone number is already in use.")
                return
            }
            updateValues["phone_number"] = newPhoneNumber
        }

        if let newEmail = newEmail {
            if !newEmail.isEmpty {
                let existingUser = await checkIfExists(column: "email", value: newEmail, userId: userId)
                if existingUser {
                    print("Error: Email is already in use.")
                    return
                }
            }
            updateValues["email"] = newEmail
        }
        if let newAddress = newAddress { updateValues["address"] = newAddress }
        if let newName = newName { updateValues["name"] = newName }

        guard !updateValues.isEmpty else {
            return
        }

        do {
            let response = try await client
                .from("users")
                .update(updateValues)
                .eq("id", value: userId)
                .execute()

            print("User updated:", response)
        } catch {
            print("Error updating user:", error)
        }
    }

    func deleteUser(userId: Int) async {
        do {
            let response = try await client
                .from("users")
                .delete()
                .eq("id", value: userId)
                .execute()

            print("User deleted:", response)
        } catch {
            print("Error deleting user:", error)
        }
    }
    func checkIfExists(column: String, value: String, userId: Int) async -> Bool {
        do {
            let response = try await Database.shared.client
                .from("users")
                .select("id")
                .eq(column, value: value)
                .neq("id", value: userId)  // Exclude the current user
                .execute()

            return !response.data.isEmpty  // If data exists, it means the value is already taken
        } catch {
            print("Error checking for existing \(column):", error)
            return false
        }
    }
    
    func updateUserPreferences(userId: Int,
                               userHeight: Int?,
                               locationSharing: Bool?,
                               measurementType: String?,
                               hapticFeedback: Bool?) async {
        
        let update = UserPreferencesUpdate(
            userHeight: userHeight,
            locationSharing: locationSharing,
            measurementType: measurementType,
            hapticFeedback: hapticFeedback
        )

        do {
            let response = try await client
                .from("users")
                .update(update)
                .eq("id", value: userId)
                .execute()

            print("Preferences updated:", response)
        } catch {
            print("Error updating preferences:", error)
        }
    }

}

// Extension for modifying emergency contaacts
extension Database {
    func addEmergencyContact(userId: Int, newEC: EmergencyContact) async {
        do {
            guard let user = await fetchUserById(userId: userId) else {
                print("User not found.")
                return
            }
            var currentContacts = user.emergencyContacts ?? []
            currentContacts.append(newEC)

            let response = try await client
                .from("users")
                .update(["emergencyContacts": currentContacts])
                .eq("id", value: userId)
                .execute()

            print("Emergency contact added successfully:", response)
        } catch {
            print("Error adding emergency contact:", error)
        }
    }
    func updateEmergencyContact(userId: Int, originalName: String, updatedContact: EmergencyContact) async {
        do {
            guard let user = await fetchUserById(userId: userId),
                  var currentContacts = user.emergencyContacts else {
                print("User or emergency contacts not found.")
                return
            }

            if let index = currentContacts.firstIndex(where: { $0.name == originalName }) {
                currentContacts[index] = updatedContact
            } else {
                print("Contact not found.")
                return
            }

            let response = try await client
                .from("users")
                .update(["emergencyContacts": currentContacts])
                .eq("id", value: userId)
                .execute()

            print("Updated contact:", response)

        } catch {
            print("Error updating emergency contact:", error)
        }
    }

    func deleteEmergencyContact(userId: Int, contactName: String) async {
        do {
            // Fetch the current contacts
            guard let user = await fetchUserById(userId: userId),
                  var currentContacts = user.emergencyContacts else {
                print("User or emergency contacts not found.")
                return
            }
            currentContacts.removeAll { $0.name == contactName }

            guard let jsonData = try? JSONEncoder().encode(currentContacts),
                  let jsonString = String(data: jsonData, encoding: .utf8) else {
                print("Failed to encode updated emergency contacts")
                return
            }

            let response = try await client
                .from("users")
                .update(["emergencyContacts": currentContacts])
                .eq("id", value: userId)
                .execute()

            print("Emergency contact removed:", response)
        } catch {
            print("Error deleting emergency contact:", error)
        }
    }

}

// Extension for fetching data
extension Database {
    func fetchUsers() async -> [User] {
        do {
            let response = try await client
                .from("users")
                .select()
                .execute()
            guard !response.data.isEmpty else {
                print("Error: No users found.")
                return []
            }

            let users = try JSONDecoder().decode([User].self, from: response.data)

            return users
        } catch {
            print("Error fetching users:", error)
            return []
        }
    }

    func fetchUserById(userId: Int) async -> User? {
        do {
            let response = try await client
                .from("users")
                .select("id, name, username, phoneNumber, emergencyContacts, createdAt, hashedPassword, saltedPassword, address, email, measurementType, userHeight, hapticFeedback, locationSharing")
                .eq("id", value: userId)
                .single()
                .execute()
            
            print("Fetched user response (raw JSON):", String(data: response.data, encoding: .utf8) ?? "No data")

            var user = try JSONDecoder().decode(User.self, from: response.data)

            if let jsonDict = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any],
                let ecString = jsonDict["emergencyContacts"] as? String,
                let ecData = ecString.data(using: .utf8) {

                do {
                    let contacts = try JSONDecoder().decode([EmergencyContact].self, from: ecData)

                    user.emergencyContacts = contacts

                } catch {
                    print("Failed to decode emergencyContacts JSON string:", error)
                }
            }

            print("Successfully parsed user object:", user)
            return user
        } catch {
            print("Error fetching user:", error)
            return nil
        }
    }
}
