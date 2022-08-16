//
//  File.swift
//  
//
//  Created by loaner on 8/6/22.
//

import Fluent
import FluentPostgresDriver
import Vapor

struct ProfessorMigrations: AsyncMigration{
    func prepare(on database: Database) async throws {
        try await database.schema("ece564server_professors")
            .id()
            .field("username", .string, .required)
            .field("password", .string, .required)
            .unique(on: "username")
            .create()
        let professor = Professor(username: "rt113", password: "ECE_564_Server")
        try await professor.create(on: database)
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("ece564server_professors")
            .delete()
    }
}
