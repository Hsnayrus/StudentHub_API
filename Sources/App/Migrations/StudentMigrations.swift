//
//  File.swift
//  
//
//  Created by loaner on 8/7/22.
//

import Fluent
import FluentPostgresDriver
import Vapor

struct StudentMigrations: AsyncMigration{
    func prepare(on database: Database) async throws {
        try await database.schema("ece564server_students")
            .id()
            .field("username", .string, .required)
            .field("password", .string, .required)
            .unique(on: "username")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("ece564server_students")
            .delete()
    }
}
