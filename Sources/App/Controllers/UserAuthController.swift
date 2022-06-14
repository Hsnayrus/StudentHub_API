//
//  File.swift
//  
//
//  Created by loaner on 5/28/22.
//

import Fluent
import Vapor

struct UserAuthController: RouteCollection{
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("user")
//        users.get(use: index)
        users.group("create"){ user in
            user.post(use: create)
        }
    }
    
//    //MARK: Index -> Render a form that enables creating a new user.
//    func index(req: Request) throws -> EventLoopFuture<View>{
//        return UserAuth.query(on: req.db).all().flatMap{users in
//            return req.view.render("UserViews/IndexView", ["users": users])
//        }
//    }
    
    //MARK: Create -> Decode the data received from the index function
    func create(req: Request) async throws -> HTTPStatus{
        let user = try req.content.decode(UserAuth.self)
        //Check if an entry for this username already exists.
        //If it does then return a 400 Bad Request.
        //Else just create a new entry and return 200OK
        let allUsers = try await  UserAuth.query(on: req.db).filter(\.$username == user.username).all()
        
        if allUsers.count == 0{
            if user.password == nil{
                let usernameData = Data(user.username.utf8)
                let usernameHashed = SHA256.hash(data: usernameData)
                user.password = usernameHashed.hex
            }
            try await user.create(on: req.db)
            return HTTPStatus(statusCode: 200)
        }
        else{
            return HTTPStatus(statusCode: 409, reasonPhrase: "User with this user id already exists.")
        }
    }
}
