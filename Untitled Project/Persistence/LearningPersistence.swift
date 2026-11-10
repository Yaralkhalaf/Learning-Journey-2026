import Foundation

/// Abstracts where the learning data lives, so previews and tests can use memory.
protocol LearningPersistence {
    func load() -> LearningData
    func save(_ data: LearningData)
}

/// Stores the data as JSON in `UserDefaults`.
struct UserDefaultsPersistence: LearningPersistence {
    private let defaults: UserDefaults
    private let key = "learningJourney.data"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> LearningData {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode(LearningData.self, from: data)
        else { return LearningData() }
        return decoded
    }

    func save(_ data: LearningData) {
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        defaults.set(encoded, forKey: key)
    }

    func reset() {
        defaults.removeObject(forKey: key)
    }
}

/// Keeps data in memory only. Used by SwiftUI previews.
final class InMemoryPersistence: LearningPersistence {
    private var data: LearningData

    init(_ data: LearningData = LearningData()) {
        self.data = data
    }

    func load() -> LearningData { data }
    func save(_ data: LearningData) { self.data = data }
}
