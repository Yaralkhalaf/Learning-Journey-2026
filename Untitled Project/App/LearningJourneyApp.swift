import SwiftUI

@main
struct LearningJourneyApp: App {
    @State private var store = LearningStore.makeForApp()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
        }
    }
}

private extension LearningStore {
    static func makeForApp() -> LearningStore {
        let persistence = UserDefaultsPersistence()
        #if DEBUG
        // Launch with `-resetData` (Scheme ▸ Arguments) to see onboarding again.
        if ProcessInfo.processInfo.arguments.contains("-resetData") {
            persistence.reset()
        }
        // Debug builds fill previous months with dummy history (see MockData.swift).
        return LearningStore(persistence: persistence, seedsMockHistory: true)
        #else
        return LearningStore(persistence: persistence)
        #endif
    }
}
