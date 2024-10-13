@testable import App
import XCTVapor
import XCTQueues

final class AccountCreationServiceTests: XCTestCase {
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

    func testCreateAccount() async throws {
        let accounts = [
            ("Bruce Wayne", "bruce@wayne.co"),
            ("Barry Allen", "nottheflash@hotmail.com"),
        ]

        for (fullname, email) in accounts {
            _ = try await app.users.create(fullname: fullname, email: email)
        }

        XCTAssertEqual(app.queues.asyncTest.jobs.count, 2, "Expected 2 jobs to have been dispatched")
    }
}
