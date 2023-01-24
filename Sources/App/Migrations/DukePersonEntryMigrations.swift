//
//  File.swift
//  
//
//  Created by loaner on 5/27/22.
//

import Fluent
import FluentPostgresDriver
import Vapor

struct DukePersonEntryMigrations: AsyncMigration{
    /*MARK: Note
     This function is never used since we cannot create
     primary keys of string type.
     The workaround this is to create a table manually
     with the appropriate types
     */
    func prepare(on database: Database) async throws {
        try await database.schema("ece564server_dukeperson_entry")
            .field("id", .string, .identifier(auto: false))
            .field("netid", .string, .required)
            .field("firstname", .string, .required)
            .field("lastname" ,.string, .required)
            .field("wherefrom", .string)
            .field("gender", .int, .required)
            .field("role", .string)
            .field("team", .string)
            .field("hobby", .string)
            .field("languages", .array(of: .string))
            .field("email", .string)
            .field("picture", .string)
            .field("movie", .string)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("ece564server_dukeperson_entry").delete()
    }
}
