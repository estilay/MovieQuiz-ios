import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter = AlertPresenter()
    private let statisticService: StatisticServiceProtocol = StatisticService()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        showLoadingIndicator()
        questionFactory.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadDataFromServer(with error: Error) {
        showNetworkError(message: error.localizedDescription)
        
    }
    
    // MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    // MARK: - Private functions
    private func setupFonts() {
        indexLabel.font = Fonts.ysDisplayMedium20
        questionTitleLabel.font = Fonts.ysDisplayMedium20
        yesButton.titleLabel?.font = Fonts.ysDisplayMedium20
        noButton.titleLabel?.font = Fonts.ysDisplayMedium20
        questionLabel.font = Fonts.ysDisplayBold23
    }
    
    private func setupUI() {
        previewImage.layer.cornerRadius = 20
        previewImage.layer.masksToBounds = true
        setupFonts()
    }

    private func show(quiz step: QuizStepViewModel) {
        previewImage.image = step.image
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.imageName) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let text = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            showResults(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        previewImage.layer.borderWidth = 8
        previewImage.layer.cornerRadius = 20
        if isCorrect {
            correctAnswers += 1
            previewImage.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            previewImage.layer.borderColor = UIColor.ypRed.cgColor
        }
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
            self.previewImage.layer.borderWidth = 0
            self.previewImage.layer.borderColor = nil
        }
    }
    
    private func showResults(quiz result: QuizResultsViewModel) {
        let gamesCount = statisticService.gamesCount
        let bestGame = statisticService.bestGame
        let totalAccuracy = statisticService.totalAccuracy
        let message = """
                \(result.text)
                Количество сыгранных квизов: \(gamesCount)
                Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", totalAccuracy))%
                """
        
        let model = AlertModel(
            alertTitle: result.title,
            alertMessage: message,
            alertButtonText: result.buttonText) { [weak self] in
            guard let self = self else { return }

            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter.showResults(in: self, model: model)
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            alertTitle: "Ошибка",
            alertMessage: message,
            alertButtonText: "Попробовать еще раз") { [weak self] in
            guard let self else { return }
                
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
                
            self.questionFactory?.requestNextQuestion()
            }
        alertPresenter.showResults(in: self, model: model)
    }
}
