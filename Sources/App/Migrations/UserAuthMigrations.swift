//
//  File.swift
//  
//
//  Created by loaner on 5/27/22.
//

import Fluent
import Vapor

struct UserAuthMigrations: AsyncMigration{
    func prepare(on database: Database) async throws{
        try await database.schema("ece564server_user_auth")
            .id()
            .field("username", .string, .required)
            .field("password", .string)
            .unique(on: "username")
            .create()
        let AdminUser = UserAuth(id: UUID(), username: "rt113", password: UUID().uuidString)
        try await AdminUser.create(on: database)
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("ece564server_user_auth").delete()
    }
}


