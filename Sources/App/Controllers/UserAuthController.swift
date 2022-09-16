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
        users.patch(use: update)
        users.group("create"){ user in
            user.post(use: create)
        }
        users.group("all"){ user in
            user.get(use: index)
        }
        users.group(":username"){user in
            user.delete(use: delete)
        }
    }
    
/*    //MARK: Index -> Render a form that enables creating a new user.
 Need basic authorization headers with either a TA user making this request, or a Professor making it
 A Professor can see all users, a TA can see all other students, students can see nothing
 */
    func index(req: Request) async throws -> [UserAuth]{
        let authHeaders = req.headers.basicAuthorization
        if let authHeaders = authHeaders {
            let currentUser = try await UserAuth.query(on: req.db).filter(\.$username == authHeaders.username).filter(\.$password == authHeaders.password).first()
            if currentUser == nil{
                return []
            }
            if currentUser!.userType == UserType.Student{
                return []
            }
            /*
             In case that the person making the request is a TA, they will be able to access
             all student entries along with their own.
             */
            else if currentUser!.userType == UserType.TA{
                var onlyStudents = try await UserAuth.query(on: req.db).filter(\.$userType == UserType.Student).all()
                onlyStudents.append(currentUser!)
                return onlyStudents
            }
            else{
                let allUsers = try await UserAuth.query(on: req.db).all()
                return allUsers
            }
        }
        else{
            return []
        }
    }
    
    //MARK: Create -> Decode the data received from the index function
/*
 Create a new entry for a user with parameters supplied in the request
 Professors can create any user,
 TAs can only create students
 Students cannot access the page
 Password field is optional in the request, if supplied, then the supplied password will be used
 else a new password will be generated according to the username
*/
    func create(req: Request) async throws -> HTTPStatus{
        
        //User to create
        let user = try req.content.decode(UserAuth.self)
        
        //Checking for basic auth headers
        guard let authHeaders = req.headers.basicAuthorization else{
            return HTTPStatus(statusCode: 401, reasonPhrase: "No credentials provided")
        }
        
        //Making sure that authHeaders have a corresponding entry in the database
        guard let authUserEntry = try await UserAuth.query(on: req.db).filter(\.$username == authHeaders.username).filter(\.$password == authHeaders.password).first() else{
            return HTTPStatus(statusCode: 400, reasonPhrase: "Invalid credentials provided")
        }
        
        //Check if student is not accessing the page
        if authUserEntry.userType == UserType.Student{
            return HTTPStatus(statusCode: 400, reasonPhrase: "Students cannot modify user entries")
        }
        else if (user.userType == UserType.Professor || user.userType == UserType.TA) && authUserEntry.userType == UserType.TA{
            return HTTPStatus(statusCode: 400, reasonPhrase: "TA(s) cannot create TA/Professor entries")
        }
        else{
            //Create a password if password is not supplied
            if user.password == nil{
                let usernameData = Data(user.username.utf8)
                let usernameHashed = SHA256.hash(data: usernameData)
                user.password = usernameHashed.hex
            }
            try await user.create(on: req.db)
            return HTTPStatus(statusCode: 201, reasonPhrase: "Entry created successfully")
        }
    }
    /*
     Delete function allows professor(s) to delete any and all users,
     TA(s) can delete all students,
     students cannot delete anything
     */
    func delete(req: Request) async throws -> HTTPStatus{
        guard let username = req.parameters.get("username") else{
            return HTTPStatus(statusCode: 404, reasonPhrase: "Invalid username Provided to delete")
        }
        guard let entry = try await UserAuth.query(on: req.db).filter(\.$username == username).first() else{
            return HTTPStatus(statusCode: 404, reasonPhrase: "Entry for this username does not exist")
        }
        if entry.userType == UserType.Professor{
            return HTTPStatus(statusCode: 400, reasonPhrase: "Cannot delete a professor's entry")
        }
        guard let authHeaders = req.headers.basicAuthorization else{
            return HTTPStatus(statusCode: 400, reasonPhrase: "No authorization headers provided" )
        }
        guard let userAuth = try await UserAuth.query(on: req.db).filter(\.$username == authHeaders.username).filter(\.$password == authHeaders.password).first() else{
            return HTTPStatus(statusCode: 400, reasonPhrase: "Invalid credentials provided")
        }
        
        if userAuth.userType == UserType.Student{
            return HTTPStatus(statusCode: 400, reasonPhrase: "Students cannot modify user entries")
        }
        else if userAuth.userType == UserType.TA && entry.userType == UserType.TA && username != userAuth.username {
            return HTTPStatus(statusCode: 400, reasonPhrase: "TAS can only delete their or other students' entries")
        }
        else{
            try await entry.delete(on: req.db)
        }
        return HTTPStatus(statusCode: 200, reasonPhrase: "User Entry Deleted Successfully")
    }
    
/*
 User's password and role can be updated using the route /user/:username
 where :username is to be replaced by the username of the entry.
 Modification rules:
 Professors can modify any and all entries
 TAs can only modify their or students' entries
 Students have no access
 Basic authorization parameters needed.
 TA(s) can update their own and students' details
 Professors can update anyone's details
 */
    func update(req: Request) async throws -> HTTPStatus{
        let userNewDetails = try req.content.decode(UserAuth.self)
        
        //Checking if entry of this username exists in database
        guard let userEntry = try await  UserAuth.query(on: req.db).filter(\.$username == userNewDetails.username).first() else{
            return HTTPStatus(statusCode: 401, reasonPhrase: "User not found")
        }
        
        //Auth details of person who is making the request
        guard let authHeaders = req.headers.basicAuthorization else{
            return HTTPStatus(statusCode: 400, reasonPhrase: "No basic auth headers provided")
        }
        
        //Find user that is making the request in the database
        guard let authUserEntry = try await UserAuth.query(on: req.db).filter(\.$username == authHeaders.username).filter(\.$password == authHeaders.password).first() else{
            return HTTPStatus(statusCode: 400, reasonPhrase: "Person trying to make request could not be found")
        }
        
        if authUserEntry.userType == UserType.Student{
            return HTTPStatus(statusCode: 404, reasonPhrase: "Student's cannot update details")
        }
        //TA cannot update other TA's details
        else if authUserEntry.userType == UserType.TA && (userEntry.userType == UserType.TA && userEntry.username != authUserEntry.username){
                return HTTPStatus(statusCode: 401, reasonPhrase: "Can only change your details as a TA")
        }
        else{
            userEntry.password = userNewDetails.password
            userEntry.userType = userNewDetails.userType
            try await userEntry.update(on: req.db)
            return HTTPStatus(statusCode: 200, reasonPhrase: "Details updated")
        }
    }
}
