import SwiftUI

@main
struct LearningJourneyApp: App {
    @State private var store = LearningStore.makeForApp()

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: RootViewModel(store: store))
        }
    }
}

private extension LearningStore {
    static func makeForApp() -> LearningStore {
        let persistence = UserDefaultsPersistence()
        #if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        // Launch with `-resetData` to start from onboarding again (as a fresh install).
        if arguments.contains("-resetData") { persistence.reset() }
        // Launch with `-mockHistory` to fill previous months with dummy data for demos.
        return LearningStore(persistence: persistence, seedsMockHistory: arguments.contains("-mockHistory"))
        #else
        return LearningStore(persistence: persistence)
        #endif
    }
}
