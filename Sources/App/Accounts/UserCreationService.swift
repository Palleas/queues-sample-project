import Queues
import Vapor
import Fluent

struct UserCreationService {
    let queue: Queue
    let database: Database

    func create(fullname: String, email: String) async throws -> User {
        let user = User(id: UUID(), fullname: fullname, email: email)
        try await user.create(on: database)

        try await queue.dispatch(SendWelcomeEmailJob.self, user.requireID())

        return user
    }
}

extension Application {
    var users: UserCreationService {
        .init(queue: queues.queue, database: db)
    }
}
