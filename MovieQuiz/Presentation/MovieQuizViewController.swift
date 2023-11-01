import UIKit

protocol MovieQuizViewProtocol: AnyObject {
    func showAnswerResult(isCorrect: Bool)
}

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswers = 0
    private var playedQuizes = 0
    
    //private var currentQuestion: QuizQuestion?
    
    private lazy var questionFactory: QuestionFactoryProtocol = {
        QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    }()
    
    private lazy var alertPresenter: AlertPresenterDelegate = {
        AlertPresenter(viewController: self)
    }()
    
    private lazy var statisticService: StatisticService = {
        StatisticServiceImplementation()
    }()
    
    private var presenter: MovieQuizPresenterProtocol!
   
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(view: self)
        showLoadingIndicator()
        questionFactory.loadData()
    }
    
    //MARK: - private methods
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func generateResultText() -> String {
        let bestGame = statisticService.bestGame
        let yourResultText = "Ваш результат: \(correctAnswers)\\\(presenter.questionsAmount)"
        let gamesCountText = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let recordText = bestGame?.textRepresention
        let avarageAccuracyText = " Средняя точность: \(String(format: "%.2F", statisticService.totalAccuracy))%"
        
        let message = [yourResultText ,gamesCountText, recordText, avarageAccuracyText].compactMap { $0 }.joined(separator: "\n")

        return message
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            playedQuizes += 1
            let resultText = generateResultText()
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: resultText,
                buttonText: "Сыграть ещё раз")
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            showAlert(quiz: viewModel)
        } else {
            questionFactory.requestNextQuestion()
        }
    }
    
    private func showAlert(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: generateResultText(),
            buttonText: "Сыграть ещё раз") { [ weak self ] in
                guard let self else { return }
                self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory.requestNextQuestion()
        }
        alertPresenter.presentAlert(with: alertModel)
    }
    
    private func formatCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"
        return dateFormatter.string(from: Date())
    }
    
    private func formatAccuracy(_ accuracy: Double) -> String {
        return String(format: "%.2f%%", accuracy)
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory.requestNextQuestion()
        }
        alertPresenter.presentAlert(with: model)
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    
    //MARK: - IBActions
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
}

// MARK: - QuestionFactoryDelegate

extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        presenter.currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
}

fileprivate struct Constants {
    static let cornerRadius: CGFloat = 20
    static let borderWidth: CGFloat = 8
}

extension MovieQuizViewController: MovieQuizViewProtocol {
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = Constants.borderWidth
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = Constants.cornerRadius
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [ weak self ] in
            guard let self = self else { return }
            self.imageView.layer.borderWidth = 0
            noButton.isEnabled = true
            yesButton.isEnabled = true
            self.showNextQuestionOrResults()
        }
    }
    
}
