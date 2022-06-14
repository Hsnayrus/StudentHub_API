//
//  File.swift
//  
//
//  Created by loaner on 5/27/22.
//

import Fluent
import Vapor

final class DukePersonEntry: Model, Content{
    static let schema: String = "ece564server_dukeperson_entry"
    
    @ID(custom: "id", generatedBy: .user)
    var id: String?
    
    @Field(key: "netid")
    var netid: String
    
    @Field(key: "firstname")
    var firstname: String
    
    @Field(key: "lastname")
    var lastname: String
    
    @Field(key: "wherefrom")
    var wherefrom: String
    
    @Field(key: "gender")
    var gender: String
    
    @Field(key: "role")
    var role: String
    
    @Field(key: "degree")
    var degree: String
    
    @Field(key: "team")
    var team: String
    
    @Field(key: "hobbies")
    var hobbies: [String]
    
    @Field(key: "languages")
    var languages: [String]
    
    @Field(key: "department")
    var department: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "picture")
    var picture: String
    
    init(){
    }
    
    init(id: String? = nil, netid: String, firstname: String, lastname: String, wherefrom: String, gender: String, role: String, degree: String, team: String, hobbies: [String], languages: [String], department: String, email: String, picture: String){
        self.id = id
        self.firstname = firstname
        self.lastname = lastname
        self.wherefrom = wherefrom
        self.gender = gender
        self.role = role
        self.degree = degree
        self.team = team
        self.hobbies = hobbies
        self.languages = languages
        self.department = department
        self.email = email
        self.picture = picture
    }
}
