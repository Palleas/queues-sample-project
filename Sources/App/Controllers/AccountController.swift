import Vapor

struct AccountController: RouteCollection {
    struct Payload: Content {
        let fullname: String
        let email: String
    }

    func boot(routes: any RoutesBuilder) throws {
        routes.post("users", use: create)
        routes.get("users", use: list)
    }

    @Sendable func list(req: Request) async throws -> [User] {
        try await User.query(on: req.db).all()
    }

    @Sendable func create(req: Request)  async throws -> HTTPStatus {
        let accounts = try req.content.decode([Payload].self)

        for account in accounts {
            _ = try await req.application.users.create(
                fullname: account.fullname,
                email: account.email
            )
        }

        return .created
    }
}
