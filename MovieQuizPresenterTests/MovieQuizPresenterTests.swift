import XCTest

@testable import MovieQuiz
final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    // MARK: - Counters
    var showQuestionCalled = 0
    var showResultsCalled = 0
    var enableButtonsCalled = 0
    var highlightImageBorderCalled = 0
    var showLoadingIndicatorCalled = 0
    var hideLoadingIndicatorCalled = 0
    var showNetworkErrorCalled = 0
    
    // MARK: - Methods
    func showQuestion(quiz step: QuizStepViewModel) {
        showQuestionCalled += 1
    }
    
    func showResults(quiz result: QuizResultsViewModel) {
        showResultsCalled += 1
    }
    
    func enableButtons(_ isEnabled: Bool) {
        enableButtonsCalled += 1
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        highlightImageBorderCalled += 1
    }
    
    func showLoadingIndicator() {
        showLoadingIndicatorCalled += 1
    }
    
    func hideLoadingIndicator() {
        hideLoadingIndicatorCalled += 1
    }
    
    func showNetworkError(message: String) {
        showNetworkErrorCalled += 1
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        
        XCTAssertEqual(viewModel.image, emptyData)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
