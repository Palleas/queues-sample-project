import Fluent

struct CreateUserMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("users")
            .id()
            .field("fullname", .string, .required)
            .field("email", .string, .required)
            .field("welcome_email_sent_at", .datetime)
            .create()

    }

    func revert(on database: any Database) async throws {
        try await database.schema("users").delete()
    }
}
