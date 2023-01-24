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
    
    @ID(custom: "id", generatedBy: .random)
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
    var gender: Int
    
    @Field(key: "role")
    var role: String
    
    @Field(key: "team")
    var team: String
    
    @Field(key: "hobby")
    var hobby: String
    
    @Field(key: "languages")
    var languages: [String]
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "picture")
    var picture: String
    
    @Field(key: "movie")
    var movie: String
    
    init(){
    }
    
    init(id: String? = nil, netid: String, firstname: String, lastname: String, wherefrom: String, gender: Int, role: String, team: String, hobby: String, languages: [String], email: String, picture: String, movie:String){
        self.id = id
        self.firstname = firstname
        self.lastname = lastname
        self.wherefrom = wherefrom
        self.gender = gender
        self.role = role
        self.team = team
        self.hobby = hobby
        self.languages = languages
        self.email = email
        self.picture = picture
        self.movie = movie
    }
}
