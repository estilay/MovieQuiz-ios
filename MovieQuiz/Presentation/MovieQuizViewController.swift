import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Properties
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenter!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Switcher: true = Mock Data, false = Real Data
        let useMockData = true  // <- Change here
        
        if useMockData {
            let mockFactory = MockQuestionFactory()
            presenter = MovieQuizPresenter(viewController: self, questionFactory: mockFactory)
        } else {
            presenter = MovieQuizPresenter(viewController: self)
        }
        
        alertPresenter = AlertPresenter()
        setupUI()
    }
    
    // MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - Functions
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
    
    func enableButtons(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }

    func showQuestion(quiz step: QuizStepViewModel) {
        previewImage.layer.borderColor = UIColor.clear.cgColor
        previewImage.image = UIImage(data: step.image) ?? UIImage()
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
        
        enableButtons(true)
    }
    
    func showResults(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
        
        let alertModel = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                self.presenter.restartGame()
            }
        )
        
        alertPresenter?.showResults(in: self, model: alertModel)
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
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
