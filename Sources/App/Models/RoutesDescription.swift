//
//  File.swift
//  
//
//  Created by loaner on 7/29/22.
//

import Fluent
import Vapor

struct RoutesDescription: Encodable{
    var httpMethod: String
    var route: String
    var description: String
}

struct AllRoutes: Encodable{
    var routes: [RoutesDescription]
}
