//
//  File.swift
//  
//
//  Created by loaner on 7/25/22.
//

import Fluent
import Vapor

struct DukePersonEntryView: Encodable{
    var firstname: String
    var lastname: String
    var id: String
    var netid: String
    var wherefrom: String
    var gender: Int
    var role: String
    var degree: String
    var team: String
    var hobbies: String
    var languages: [String]
    var department: String
    var email: String
    var picture: String
    var color: String
    var movie:String
    
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
        self.movie = dukePerson.movie
        self.color = color
    }
}


