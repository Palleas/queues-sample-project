import Queues
import Foundation
import Fluent

struct SendWelcomeEmailJob: AsyncJob {
    func dequeue(_ context: QueueContext, _ payload: UUID) async throws {
        // Pretending something is happening
        try await Task.sleep(for: .milliseconds(100))

        try await User
            .query(on: context.application.db)
            .set(\.$welcomeEmailSentAt, to: Date()).filter(\.$id == payload)
            .limit(1)
            .update()
    }
}
