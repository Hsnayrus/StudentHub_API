import Fluent
import Vapor

func routes(_ app: Application) throws {
    //    app.middleware.use(EnsureIDCorrect())
    try app.register(collection: UserAuthController())
    try app.register(collection: DukePersonEntryController())
    app.get{ req -> EventLoopFuture<View> in
        return req.view.render("HomePage.html")
    }
}
