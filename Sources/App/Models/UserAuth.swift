//
//  File.swift
//  
//
//  Created by loaner on 5/21/22.
//

import Fluent
import Vapor

final class UserAuth: Model, Content{
    static let schema: String = "ece564server_user_auth"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @OptionalField(key: "password")
    var password: String?
    
    init(){
        
    }
    
    init(id: UUID? = nil, username: String, password: String){
        self.id = id
        self.username = username
        self.password = password
    }
}
