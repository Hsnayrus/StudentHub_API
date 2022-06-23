//
//  File.swift
//  
//
//  Created by loaner on 5/28/22.
//

import Fluent
import Vapor

struct DukePersonEntryView: Encodable{
    var firstname: String
    var lastname: String
    var id: String
    var netid: String
    var wherefrom: String
    var gender: String
    var role: String
    var degree: String
    var team: String
    var hobbies: [String]
    var languages: [String]
    var department: String
    var email: String
    var picture: String
    var color: String
    
    init(dukePerson: DukePersonEntry, color: String){
        self.firstname = dukePerson.firstname
        self.lastname = dukePerson.lastname
        self.id = dukePerson.id!
        self.netid = dukePerson.netid
        self.wherefrom = dukePerson.wherefrom
        self.gender = dukePerson.gender
        self.role = dukePerson.role
        self.degree = dukePerson.degree
        self.team = dukePerson.team
        self.hobbies = dukePerson.hobbies
        self.languages = dukePerson.languages
        self.department = dukePerson.department
        self.email = dukePerson.email
        self.picture = dukePerson.picture
        self.color = color
    }
}


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
        dukePeople.group(":id"){dukePerson in
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
            return req.view.render("DukePersonViews/DukePeopleIndex", ["dukePeople": allPeople])
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
            return HTTPStatus(statusCode: 200, reasonPhrase: "Updated existing entry for \(dukePerson.netid)")
        }
    }
    
    func getAllEntries(req: Request) throws -> EventLoopFuture<[DukePersonEntry]>{
        return DukePersonEntry.query(on: req.db).all()
    }
    
    func deleteEntry(req: Request) throws -> EventLoopFuture<HTTPStatus>{
        DukePersonEntry.find(req.parameters.get("songID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
    
}


