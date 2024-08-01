import Foundation

struct QuizQuestion {
    let image: ImageType
    let text: String
    let correctAnswer: Bool
}

enum ImageType {
    case string(String)
    case data(Data)
}
