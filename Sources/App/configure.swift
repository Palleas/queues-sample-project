import Vapor
import QueuesRedisDriver
import Queues
import FluentSQLiteDriver
import Fluent
import Metrics

import StatsdClient

public func configure(_ app: Application) async throws {
    try app.queues.use(.redis(url: "redis://0.0.0.0:6379"))
    app.queues.add(SendWelcomeEmailJob())
    try app.queues.startInProcessJobs()

    app.databases.use(.sqlite(.memory), as: .sqlite)
    app.migrations.add(CreateUserMigration())
    try await app.autoMigrate()

    let statsdClient = try StatsdClient(host: "0.0.0.0", port: 8125)

    MetricsSystem.bootstrap(statsdClient)

    try app.register(collection: AccountController())
}
