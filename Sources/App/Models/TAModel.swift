//
//  File.swift
//  
//
//  Created by loaner on 8/6/22.
//

import Fluent
import Vapor

final class TA: Model, Content{
    
    static let schema = "ece564server_tas"
    
    @ID(key: .id)
    var id:UUID?
    
    @Field(key: "username")
    var username: String
    
    @OptionalField(key: "password")
    var password: String?
    
    init(){
        
    }
    /*
     Initializer with only username. Here the password is generated based on the username
     The password is a SHA256 hashed value of the username. ID is generated by the code.
     */
    init(username: String){
        self.id = UUID()
        self.username = username
        let usernameData = Data(username.utf8)
        let usernameHashed = SHA256.hash(data: usernameData)
        self.password = usernameHashed.hex
    }
    
    
    /*
     Initialize a TA object with the provided username and password.
     ID is generated by the code
     */
    init(id: UUID? = nil, username: String, password: String){
        self.id = UUID()
        self.username = username
        self.password = password
    }
}

