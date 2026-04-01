import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func showQuestion(quiz step: QuizStepViewModel)
    func showResults(quiz result: QuizResultsViewModel)
    
    func enableButtons(_ isEnabled: Bool)
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}
