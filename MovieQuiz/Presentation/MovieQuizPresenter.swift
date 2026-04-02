import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private let statisticService: StatisticServiceProtocol!
    private let questionFactory: QuestionFactoryProtocol
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    var currentQuestion: QuizQuestion?
    let questionsAmount: Int = 10
    var correctAnswers: Int = 0
    private var currentQuestionIndex = 0
    
    init(viewController: MovieQuizViewControllerProtocol,
         questionFactory: QuestionFactoryProtocol) {
        self.viewController = viewController
        self.questionFactory = questionFactory
        self.statisticService = StatisticService()
        
        if let factoryWithDelegate = questionFactory as? QuestionFactory {
            factoryWithDelegate.delegate = self
        } else if let mockFactory = questionFactory as? MockQuestionFactory {
            mockFactory.delegate = self
        }
        
        self.questionFactory.loadData()
        viewController.showLoadingIndicator()
    }
    
    convenience init(viewController: MovieQuizViewControllerProtocol) {
        let realFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: nil)
        self.init(viewController: viewController, questionFactory: realFactory)
    }

    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory.requestNextQuestion()
    }
    
    func didFailToLoadDataFromServer(with error: Error) {
        viewController?.hideLoadingIndicator()
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.showQuestion(quiz: viewModel)
        }
    }
    
    // MARK: - Game Quiz Logic
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory.requestNextQuestion()
        viewController?.enableButtons(true)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: model.image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    // MARK: - Answer Processing
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }

        let givenAnswer = isYes
        let isCorrect = givenAnswer == currentQuestion.correctAnswer
        
        if isCorrect {
            correctAnswers += 1
        }

        proceedWithAnswer(isCorrect: isCorrect)
    }

    private func proceedWithAnswer(isCorrect: Bool) {
        viewController?.enableButtons(false)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            
            self.proceedToNextQuestionOrResults()
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let text = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            viewController?.showResults(quiz: viewModel)
            self.viewController?.enableButtons(true)
        } else {
            switchToNextQuestion()
            questionFactory.requestNextQuestion()
            self.viewController?.enableButtons(true)
        }
    }
    
    func makeResultsMessage() -> String {
        let bestGame = statisticService.bestGame
        
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultMessage
    }
}
