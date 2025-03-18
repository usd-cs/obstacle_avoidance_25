//
//  Database.swift
//  obstacle_avoidance
//
//  Created by Austin Lim on 2/27/25.
//

import Supabase
import Foundation

class Database{
    static let shared = Database()
    
    let client: SupabaseClient
  
    // swiftlint:disable line_length
    public init(){
        self.client = SupabaseClient(supabaseURL: URL(string: "https://fcifaepenormdpkdqypw.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZjaWZhZXBlbm9ybWRwa2RxeXB3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA1MjY5NDksImV4cCI6MjA1NjEwMjk0OX0.zkrh1J8WPY8iMMp01e3xOR5NpyCNXEzk1QFg6bcBmQw")
    }
    // swiftlint:enable line_length
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
