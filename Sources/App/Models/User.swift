import Foundation
import Fluent
import Vapor

final class User: Model, Content, @unchecked Sendable {
    static var schema: String { "users" }

    @ID
    var id: UUID?

    @Field(key: "fullname")
    var fullname: String

    @Field(key: "email")
    var email: String

    @Field(key: "welcome_email_sent_at")
    var welcomeEmailSentAt: Date?

    init() {}

    init(id: UUID, fullname: String, email: String) {
        self.id = id
        self.fullname = fullname
        self.email = email
    }
}
