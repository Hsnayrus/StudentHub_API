import Fluent
import Vapor

func routes(_ app: Application) throws {
//    app.middleware.use(EnsureIDCorrect())
    try app.register(collection: UserAuthController())
    try app.register(collection: DukePersonEntryController())
    app.get{ req -> EventLoopFuture<View> in
        let routes = app.routes.all
        var routeArray: AllRoutes = AllRoutes(routes: [])
        for route in routes{
            let routePath = route.path
            var actualRoute: String = "/"
            for path in routePath{
                actualRoute = actualRoute + path.description + "/"
            }
            let currentRoute = RoutesDescription(httpMethod: route.method.string, route: actualRoute, description: "")
            routeArray.routes.append(currentRoute)
//            print(currentRoute)
        }
        return req.view.render("HomePage", ["routes": routeArray.routes])
    }.description("Home Page")
}
