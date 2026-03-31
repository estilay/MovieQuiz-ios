import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewController?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    var currentQuestion: QuizQuestion?
    let questionsAmount: Int = 10
    var correctAnswers: Int = 0
    private var currentQuestionIndex = 0
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadDataFromServer(with error: any Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func loadDataQuiz() {
        viewController?.showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    func setupQuestionFactory() {
        questionFactory = QuestionFactory(
            moviesLoader: MoviesLoader(),
            delegate: self
        )
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: model.imageName,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = isYes
        let isCorrect = givenAnswer == currentQuestion.correctAnswer
        
        if isCorrect {
            correctAnswers += 1
        }
        
        viewController?.showAnswerResult(isCorrect: isCorrect)
    }
    

    
    func showNextQuestionOrResults() {
        if isLastQuestion() {
            let text = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            viewController?.showResults(quiz: viewModel)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func restartGame() {
            currentQuestionIndex = 0
            correctAnswers = 0
            questionFactory?.requestNextQuestion()
        }
}
