import Foundation



final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correct
        case bestGame
        case gamesCount
        case total
        case date
    }
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.correct.rawValue)
            let total = storage.integer(forKey: Keys.total.rawValue)
            let date = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
            
        }
    }
    
    var totalAccuracy: Double {
        let correct = storage.double(forKey: Keys.correct.rawValue)
        let total = storage.double(forKey: Keys.total.rawValue)
        guard total != 0 else { return 0 }
        return (correct / total) * 100
    }
    
    func store(correct count: Int, total amount: Int) {
        let newGameResult = GameResult(correct: count, total: amount, date: Date())
        let currentCorrect = storage.integer(forKey: Keys.correct.rawValue)
        let currentTotal = storage.integer(forKey: Keys.total.rawValue)
        storage.set(currentCorrect + count, forKey: Keys.correct.rawValue)
        storage.set(currentTotal + amount, forKey: Keys.total.rawValue)
        
        if newGameResult.isBetterThan(bestGame) {
            bestGame = newGameResult
        }
        gamesCount += 1
    }
}

