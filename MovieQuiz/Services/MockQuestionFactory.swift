import UIKit

final class MockQuestionFactory: QuestionFactoryProtocol {
    weak var delegate: QuestionFactoryDelegate?
    private var mockQuestions: [QuizQuestion] = []
    
    init() {
        setupMockQuestions()
    }
    
    private func setupMockQuestions() {
        let godfatherImage = UIImage(named: "The Godfather")?.pngData() ?? Data()
        let darkKnightImage = UIImage(named: "The Dark Knight")?.pngData() ?? Data()
        let killBillImage = UIImage(named: "Kill Bill")?.pngData() ?? Data()
        let avengersImage = UIImage(named: "The Avengers")?.pngData() ?? Data()
        let deadpoolImage = UIImage(named: "Deadpool")?.pngData() ?? Data()
        let greenKnightImage = UIImage(named: "The Green Knight")?.pngData() ?? Data()
        let oldImage = UIImage(named: "Old")?.pngData() ?? Data()
        let iceAgeImage = UIImage(named: "The Ice Age Adventures of Buck Wild")?.pngData() ?? Data()
        let teslaImage = UIImage(named: "Tesla")?.pngData() ?? Data()
        let vivariumImage = UIImage(named: "Vivarium")?.pngData() ?? Data()
    
        mockQuestions = [
                   QuizQuestion(
                       image: godfatherImage,
                       text: "Рейтинг этого фильма больше чем 6?",
                       correctAnswer: true),
                   QuizQuestion(
                       image: darkKnightImage,
                       text: "Рейтинг этого фильма больше чем 6?",
                       correctAnswer: true),
                   QuizQuestion(
                       image: killBillImage,
                       text: "Рейтинг этого фильма больше чем 6?",
                       correctAnswer: true),
                   QuizQuestion(
                       image: avengersImage,
                       text: "Рейтинг этого фильма больше чем 3?",
                       correctAnswer: true),
                   QuizQuestion(
                       image: deadpoolImage,
                       text: "Рейтинг этого фильма больше чем 6?",
                       correctAnswer: true),
                   QuizQuestion(
                       image: greenKnightImage,
                       text: "Рейтинг этого фильма больше чем 6?",
                       correctAnswer: true),
                   QuizQuestion(
                       image: oldImage,
                       text: "Рейтинг этого фильма больше чем 7?",
                       correctAnswer: false),
                   QuizQuestion(
                       image: iceAgeImage,
                       text: "Рейтинг этого фильма больше чем 6?",
                       correctAnswer: false),
                   QuizQuestion(
                       image: teslaImage,
                       text: "Рейтинг этого фильма больше чем 8?",
                       correctAnswer: false),
                   QuizQuestion(
                       image: vivariumImage,
                       text: "Рейтинг этого фильма больше чем 6?",
                       correctAnswer: false)
               ]
    }
    
    func requestNextQuestion() {
        let index = Int.random(in: 0..<mockQuestions.count)
        let question = mockQuestions[index]
        delegate?.didReceiveNextQuestion(question: question)
    }
    
    func loadData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.delegate?.didLoadDataFromServer()
        }
    }
}
