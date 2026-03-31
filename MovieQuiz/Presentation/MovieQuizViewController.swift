import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Properties
    private var presenter: MovieQuizPresenter!
    private var alertPresenter = AlertPresenter()
    private var statisticService: StatisticService?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statisticService = StatisticService()
        presenter = MovieQuizPresenter(viewController: self)
        setupUI()
    }
    
    // MARK: - QuestionFactoryDelegate

    
    // MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
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

    func show(quiz step: QuizStepViewModel) {
        previewImage.image = UIImage(data: step.image) ?? UIImage()
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
    }
    
//    private func showNextQuestionOrResults() {
//        if presenter.isLastQuestion() {
//            let text = "Вы ответили на \(presenter.correctAnswers) из 10, попробуйте еще раз!"
//            let viewModel = QuizResultsViewModel(
//                title: "Этот раунд окончен!",
//                text: text,
//                buttonText: "Сыграть ещё раз")
//            showResults(quiz: viewModel)
//        } else {
//            presenter.switchToNextQuestion()
//        }
//    }
    
    func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isYes: isCorrect)
        previewImage.layer.borderWidth = 8
        previewImage.layer.cornerRadius = 20
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
            self.previewImage.layer.borderWidth = 0
            self.previewImage.layer.borderColor = nil
            
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    func showResults(quiz result: QuizResultsViewModel) {
        var message = result.text
        if let statisticService = statisticService {
            statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)

            let bestGame = statisticService.bestGame

            let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let currentGameResultLine = "Ваш результат: \(presenter.correctAnswers)\\\(presenter.questionsAmount)"
            let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
            + " (\(bestGame.date.dateTimeString))"
            let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"

            let resultMessage = [
                currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
            ].joined(separator: "\n")

            message = resultMessage
        }
        
        let model = AlertModel(title: result.title, message: message, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
        
        self.presenter.restartGame()
        }
        
        alertPresenter.showResults(in: self, model: model)
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert)

        let action = UIAlertAction(title: "Попробовать еще раз",
                                   style: .default) { [weak self] _ in
            guard let self = self else { return }

            self.presenter.restartGame()
        }

        alert.addAction(action)
    }
}
