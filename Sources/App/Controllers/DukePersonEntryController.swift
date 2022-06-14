//
//  File.swift
//  
//
//  Created by loaner on 5/28/22.
//

import Fluent
import Vapor

struct DukePersonEntryController: RouteCollection{
    func boot(routes: RoutesBuilder) throws {
        let dukePeople = routes.grouped("entries")
        dukePeople.get(use: index)
        dukePeople.group("create"){ dukePerson in
            dukePerson.get(use: createForm)
            dukePerson.post(use: create)
        }
        dukePeople.group("all"){dukePerson in
            dukePerson.get(use: getAllEntries)
        }
    }
    
    //MARK: Index -> Show all entries
    func index(req: Request) throws -> EventLoopFuture<View> {
        return DukePersonEntry.query(on: req.db).all().flatMap{ allDukePeople in
            return req.view.render("DukePersonViews/DukePeopleIndex", ["dukePeople": allDukePeople])
        }
    }
    
    func createForm(req: Request) -> EventLoopFuture<View>{
        print("coming here")
        return req.view.render("DukePersonViews/CreateEntry")
    }
    
    /*
     MARK: Create/Update a new entry
     Checks if an entry exists for the net id received in the request.
     If it does, then update everything except ID and NetID.
     Otherwise, create a new entry for that NetID
     */
    func create(req: Request) async throws -> HTTPStatus{
        let authHeader = req.headers.basicAuthorization
        let dukePerson = try req.content.decode(DukePersonEntry.self)
        
        if authHeader == nil{
            return HTTPStatus(statusCode: 401, reasonPhrase: "No authorization details provided.")
        }
        print("AuthHeader is not nil")
        //Basic sanity check to ensure that NetID in the request and client's username in Authorization field match.
        //This is done because we want people to only update/delete their own entries
        if authHeader!.username != dukePerson.netid{
            return HTTPStatus(statusCode: 401, reasonPhrase: "Unauthorized access, cannot modify another person's data")
        }
        print("Usernames same")
        let findUserInTable = try await UserAuth.query(on: req.db).filter(\.$username == authHeader!.username).all()
        
        if findUserInTable.count == 0{
            return HTTPStatus(statusCode: 401, reasonPhrase: "User with NetID \(dukePerson.netid) doesn't exist.")
        }
        print("User found in table")
        
        let userFound = findUserInTable.first!
        
        if userFound.username != authHeader!.username || userFound.password != authHeader!.password{
            return HTTPStatus(statusCode: 401, reasonPhrase: "Invalid credentials provided")
        }
        print("User verified")
        let values = try await DukePersonEntry.query(on: req.db).filter(\.$netid == dukePerson.netid).all()
        
        if values.count == 0{
            dukePerson.id = UUID().uuidString
            try await dukePerson.create(on: req.db)
            print("Creating new value")
            return HTTPStatus(statusCode: 200, reasonPhrase: "Created a new DukePerson")
        }
        else{
            let foundPerson = values.first!
            foundPerson.firstname = dukePerson.firstname
            foundPerson.lastname = dukePerson.lastname
            foundPerson.wherefrom = dukePerson.wherefrom
            foundPerson.gender = dukePerson.gender
            foundPerson.role = dukePerson.role
            foundPerson.degree = dukePerson.degree
            foundPerson.team = dukePerson.team
            foundPerson.hobbies = dukePerson.hobbies
            foundPerson.languages = dukePerson.languages
            foundPerson.department = dukePerson.department
            foundPerson.email = dukePerson.email
            foundPerson.picture = dukePerson.picture
            try await foundPerson.update(on: req.db)
//            print("Updating existing values for \(foundPerson.lastname), \(foundPerson.firstname) OR \(foundPerson.netid)")
            return HTTPStatus(statusCode: 200, reasonPhrase: "Updated existing entry for \(dukePerson.netid)")
        }
    }
    
    func getAllEntries(req: Request) throws -> EventLoopFuture<[DukePersonEntry]>{
        return DukePersonEntry.query(on: req.db).all()
    }
    
}


