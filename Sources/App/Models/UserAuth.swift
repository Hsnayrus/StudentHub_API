//
//  File.swift
//  
//
//  Created by loaner on 5/21/22.
//

import Fluent
import Vapor

enum UserType: String, Codable{
    case Professor
    case TA
    case Student
}

final class UserAuth: Model, Content{
    static let schema: String = "ece564server_user_auth"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @OptionalField(key: "password")
    var password: String?
    
    @Enum(key: "user_type")
    var userType: UserType
    
    init(){
        
    }
    
    init(id: UUID? = nil, username: String, password: String? = nil, userType: UserType){
        self.id = id
        self.username = username
        if password != nil{
            self.password = password
        }
        else{
            let usernameData = Data(self.username.utf8)
            let usernameHashed = SHA256.hash(data: usernameData)
            self.password = usernameHashed.hex
        }
        self.password = password
        self.userType = userType
    }
}
