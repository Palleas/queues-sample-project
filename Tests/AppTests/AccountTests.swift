import XCTest
@testable import App
import XCTVapor
import XCTQueues

final class AccountTests: XCTestCase {
    var app: Application!

    override func setUp() async throws {
        self.app = try await Application.make(.testing)
        try await configure(app)

        // Override testing
        app.queues.use(.asyncTest)
    }

    override func tearDown() async throws {
        try await self.app.asyncShutdown()
        self.app = nil
    }

    func testAccountCreation() async throws {
        let client = APIClient(tester: app)
        let response = try await client.createUsers([
            ("Bruce Wayne", "bruce@wayne.co"),
            ("Hal Jordan", "hal@gmail.com"),
            ("Barry Allen", "definitelynottheflash@gmail.com"),
        ])
        XCTAssertEqual(response.status, .created)

        try await app.queues.queue.worker.run()

        let users = try await client.listUsers()
        XCTAssertEqual(users.count, 3)
        XCTAssertTrue(users.allSatisfy { $0.welcomeEmailSentAt != nil })

    }
}

struct APIClient {
    let tester: XCTApplicationTester

    struct UserCreationBody: Content {
        let fullname: String
        let email: String
    }

    func createUsers(_ list: [(String, String)]) async throws -> XCTHTTPResponse {
        var request = XCTHTTPRequest(
            method: .POST,
            url: "/users",
            headers: ["Content-Type":"application/json"],
            body: .init()
        )
        try request.content.encode(list.map(UserCreationBody.init(fullname:email:)))

        return try await tester.performTest(request: request)
    }

    func listUsers() async throws -> [User] {
        let response = try await tester.performTest(
            request: XCTHTTPRequest(
                method: .GET,
                url: "/users",
                headers: [:],
                body: .init()
            )
        )

        return try response.content.decode([User].self)
    }
}
