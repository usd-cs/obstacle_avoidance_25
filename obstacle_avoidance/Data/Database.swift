//
//  Database.swift
//  obstacle_avoidance
//
//  Created by Austin Lim on 2/27/25.
//

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



extension Database{
    func addUser(username: String, phoneNumber: String, emergencyContact: EmergencyContact) async{
        print("Adding user:", username)
        
        do{
            let newUser = User(
                            id: nil,
                            username: username,
                            phoneNumber: phoneNumber,
                            emergencyContact: emergencyContact,
                            createdAt: nil
                        )

            let response = try await client
                           .from("users")
                           .insert([newUser])
                           .execute()

            print("User added successfully:", response)
        }catch{
            print("Error adding user:", error)
        }
    }
    
    func updateUser(userId: UUID, newUsername: String?, newPhoneNumber: String?) async {
            var updateValues: [String: String] = [:]
            if let newUsername = newUsername { updateValues["username"] = newUsername }
            if let newPhoneNumber = newPhoneNumber { updateValues["phone_number"] = newPhoneNumber }

            do {
                let response = try await client
                    .from("users")
                    .update(updateValues)
                    .eq("id", value: userId.uuidString)
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
}

//Extension for modifying emergency contaacts
extension Database {
    func updateEmergencyContact(userId: Int, newEC: EmergencyContact) async {
        do {
            let response = try await client
                .from("users")
                .update(["emergency_contact": newEC])
                .eq("id", value: userId)
                .execute()

            print("Emergency contact updated:", response)
        } catch {
            print("Error updating emergency contact:", error)
        }
    }
    func deleteEmergencyContact(userId: UUID) async {

        do {
            let response = try await client
                .from("users")
                .update(["emergency_contact": EmergencyContact.empty])
                .eq("id", value: userId.uuidString)
                .execute()

            print("Emergency contact removed:", response)
        } catch {
            print("Error deleting emergency contact:", error)
        }
    }
}

//Extension for fetching data
extension Database {
    func fetchUsers() async -> [User] {

        do {
            let response = try await client
                .from("users")
                .select()
                .execute()

            let jsonString = String(data: response.data, encoding: .utf8) ?? "No data"
            print("Raw JSON Response:", jsonString)

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
                .select()
                .eq("id", value: userId)
                .single()
                .execute()

            let user = try JSONDecoder().decode(User.self, from: response.data)
            return user
        } catch {
            print("Error fetching user:", error)
            return nil
        }
    }
}
