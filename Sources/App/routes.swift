import Fluent
import Vapor

func routes(_ app: Application) throws {
//    app.middleware.use(EnsureIDCorrect())
    try app.register(collection: UserAuthController())
    try app.register(collection: DukePersonEntryController())
}
