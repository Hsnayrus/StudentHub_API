//
//  File.swift
//  
//
//  Created by loaner on 8/7/22.
//

import Fluent
import Vapor

final class Student: Model, Content{
    static let schema = "ece564server_students"
    
    @ID
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password")
    var password: String
    
    init() { }
    
    init(id: UUID? = nil, username: String, password: String){
        self.id = UUID()
        self.username = username
        self.password = password
    }
    
    init(username: String, password: String){
        self.id = UUID()
        self.username = username
        self.password = password
    }
}
