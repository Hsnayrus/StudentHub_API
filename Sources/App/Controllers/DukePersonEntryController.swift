//
//  File.swift
//  
//
//  Created by loaner on 5/28/22.
//

import Fluent
import Vapor
import AppKit

struct DukePersonEntryController: RouteCollection{
    func boot(routes: RoutesBuilder) throws {
        let dukePeople = routes.grouped("entries")
        dukePeople.get(use: index)
        dukePeople.group("create"){ dukePerson in
            dukePerson.post(use: create)
        }
        dukePeople.group("all"){dukePerson in
            dukePerson.get(use: getAllEntries)
        }
        dukePeople.group(":netid"){dukePerson in
            dukePerson.get(use: getEntryById)
            dukePerson.put(use: updateEntryById)
            dukePerson.delete(use: deleteEntry)
        }
    }
    
    //MARK: Index -> Show all entries
    func index(req: Request) throws -> EventLoopFuture<View> {
        return DukePersonEntry.query(on: req.db).all().flatMap{ allDukePeople in
            var allPeople: [DukePersonEntryView] = [DukePersonEntryView]()
            for person in allDukePeople{
                let idHashed = person.id!.hashValue
                let constant = idHashed & 0xFFFFFF
                let hexString = String(format: "%06x", constant)
                let color = hexString.suffix(6).uppercased()
                allPeople.append(DukePersonEntryView(dukePerson: person, color: color))
            }
            
            return req.leaf.render("DukePersonViews/DukePeopleIndex.leaf", ["dukePeople": allPeople])
//            return req.view.render("DukePersonViews/DukePeopleIndex.leaf", ["dukePeople": allPeople])
        }
    }
    
    /*
     MARK: Create/Update a new entry
     First checks if proper basicAuthorization header is received.
     A proper basicAuthorization header is NetID:password.
     The dukePersonEntry that a user is trying to create should
     have their credentials already in the user table.
     For example, if sj346 wants to create/update their data on
     the server, they have to send their NetID:password in the
     basicAuthorization header.
     Once that is done, the user's entry is searched in the db.
     If an entry exists, everything except the NetID and ID of that
     dukePerson is replaced, else a new entry will be created.
     In the request, the ID parameter is optional.
     */
    func create(req: Request) async throws -> HTTPStatus{
        let authHeader = req.headers.basicAuthorization
        let dukePerson = try req.content.decode(DukePersonEntry.self)
        
        if authHeader == nil{
            return HTTPStatus(statusCode: 401, reasonPhrase: "No authorization details provided.")
        }
        //Basic sanity check to ensure that NetID in the request and client's username in Authorization field match.
        //This is done because we want people to only update/delete their own entries
        if authHeader!.username != dukePerson.netid{
            return HTTPStatus(statusCode: 401, reasonPhrase: "Unauthorized access, cannot modify another person's data")
        }
        let findUserInTable = try await UserAuth.query(on: req.db).filter(\.$username == authHeader!.username).all()
        
        if findUserInTable.count == 0{
            return HTTPStatus(statusCode: 401, reasonPhrase: "User with NetID \(dukePerson.netid) doesn't exist.")
        }
        
        let userFound = findUserInTable.first!
        
        if userFound.username != authHeader!.username || userFound.password != authHeader!.password{
            return HTTPStatus(statusCode: 401, reasonPhrase: "Invalid credentials provided")
        }
        let values = try await DukePersonEntry.query(on: req.db).filter(\.$netid == dukePerson.netid).all()
        
        if values.count == 0{
            dukePerson.id = UUID().uuidString
            try await dukePerson.create(on: req.db)
            return HTTPStatus(statusCode: 200, reasonPhrase: "Created a new DukePerson")
        }
        else{
            return HTTPStatus(statusCode: 400, reasonPhrase: "Entry already exists")
        }
    }
    
    func getAllEntries(req: Request) async throws -> [DukePersonEntry]{
        let authHeaders = req.headers.basicAuthorization
        
        if let authHeaders = authHeaders{
            
            //Checking if these credentials match with ones existing in the database
            guard (try await UserAuth.query(on: req.db).filter(\.$username == authHeaders.username).filter(\.$password == authHeaders.password).first()) != nil else{
                throw Abort(HTTPResponseStatus(statusCode: 401, reasonPhrase: "User does not exist"))
            }
            
            let allUsers = try await DukePersonEntry.query(on: req.db).all()
            return allUsers
            
        }
        else{
            throw Abort(HTTPResponseStatus(statusCode: 401, reasonPhrase: "No credentials provided"))
        }
    }
    
    func deleteEntry(req: Request) async throws -> HTTPStatus{
        guard let authHeaders = req.headers.basicAuthorization else{
            return HTTPStatus(statusCode: 404, reasonPhrase: "No credentials Provided")
        }
        guard let netid = req.parameters.get("netid") else {
            return HTTPStatus(statusCode: 400, reasonPhrase: "Invalid ID provided")
        }
        if netid != authHeaders.username{
            return HTTPStatus(statusCode: 400, reasonPhrase: "Can only delete your own entry")
        }
        
        guard let authUserEntry = try await UserAuth.query(on: req.db).filter(\.$username == authHeaders.username).filter(\.$password == authHeaders.password).first() else {
            return HTTPStatus(statusCode: 404, reasonPhrase: "No entry for these credentials exists")
        }
        
        guard let entry = try await DukePersonEntry.query(on: req.db).filter(\.$netid == authUserEntry.username).first() else{
            return HTTPStatus(statusCode: 400, reasonPhrase: "ID doesn't exist")
        }
        try await entry.delete(on: req.db)
        return HTTPStatus(statusCode: 200)
//        DukePersonEntry.find(req.parameters.get("id"), on: req.db)
//            .unwrap(or: Abort(.notFound))
//            .flatMap { $0.delete(on: req.db) }
//            .transform(to: .ok)
    }
    
    func getEntryById(req: Request) async throws -> DukePersonEntry{
        guard let authHeaders = req.headers.basicAuthorization else{
            throw Abort(HTTPResponseStatus(statusCode: 401, reasonPhrase: "No credentials Provided"))
        }
        guard let id = req.parameters.get("netid") else {
            throw Abort(HTTPResponseStatus(statusCode: 400, reasonPhrase: "Invalid NetID provided"))
        }
        if id != authHeaders.username{
            throw Abort(HTTPResponseStatus(statusCode: 400, reasonPhrase: "Can only retrieve your own entry"))
        }
        
        guard let authUserEntry = try await UserAuth.query(on: req.db).filter(\.$username == authHeaders.username).filter(\.$password == authHeaders.password).first() else {
            throw Abort(HTTPResponseStatus(statusCode: 401, reasonPhrase: "No entry for these credentials exists"))
        }
        
        guard let entry = try await DukePersonEntry.query(on: req.db).filter(\.$netid == authUserEntry.username).first() else{
            throw Abort(HTTPResponseStatus(statusCode: 400, reasonPhrase: "NetID doesn't exist"))
        }
        
        return entry
    }
    
    func updateEntryById(req: Request)async throws -> HTTPStatus{
        guard let authHeaders = req.headers.basicAuthorization else{
            return HTTPStatus(statusCode: 404, reasonPhrase: "No credentials Provided")
        }
        guard let netid = req.parameters.get("netid") else {
            return HTTPStatus(statusCode: 400, reasonPhrase: "Invalid ID provided")
        }
        if netid != authHeaders.username{
            return HTTPStatus(statusCode: 400, reasonPhrase: "Can only delete your own entry")
        }
        
        guard let authUserEntry = try await UserAuth.query(on: req.db).filter(\.$username == authHeaders.username).filter(\.$password == authHeaders.password).first() else {
            return HTTPStatus(statusCode: 404, reasonPhrase: "No entry for these credentials exists")
        }
        
        guard let entry = try await DukePersonEntry.query(on: req.db).filter(\.$netid == authUserEntry.username).first() else{
            return HTTPStatus(statusCode: 400, reasonPhrase: "ID doesn't exist")
        }
        
        let newDetails = try req.content.decode(DukePersonEntry.self)
        
        entry.firstname  = newDetails.firstname
        entry.lastname   = newDetails.lastname
        entry.wherefrom  = newDetails.wherefrom
        entry.gender     = newDetails.gender
        entry.role       = newDetails.role
        entry.degree     = newDetails.degree
        entry.team       = newDetails.team
        entry.hobbies    = newDetails.hobbies
        entry.languages  = newDetails.languages
        entry.department = newDetails.department
        entry.email      = newDetails.email
        entry.picture    = newDetails.picture
        try await entry.update(on: req.db)
        return HTTPStatus(statusCode: 200, reasonPhrase: "Updated existing entry for \(newDetails.netid)")
        
    }
}


