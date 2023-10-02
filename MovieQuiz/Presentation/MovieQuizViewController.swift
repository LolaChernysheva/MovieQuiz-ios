import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var playedQuizes = 0
    
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    
    private lazy var questionFactory: QuestionFactoryProtocol = {
        QuestionFactory(delegate: self)
    }()
    
    private lazy var alertPresenter: AlertPresenterDelegate = {
        AlertPresenter(viewController: self)
    }()
    
    private lazy var statisticService: StatisticService = {
        StatisticServiceImplementation()
    }()
   
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory.requestNextQuestion()
    }
    
    //MARK: - private methods
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        currentQuestionIndex += 1
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex)/\(questionsAmount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
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
    
    private func isAnswerCorrect(answer: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let isCorrect = currentQuestion.correctAnswer == answer
        showAnswerResult(isCorrect: isCorrect)
    }
    
    private func generateResultText() -> String {
        let bestGame = statisticService.bestGame
        let gamesCountText = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let yourResultText = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let recordText = bestGame?.textRepresention
        let avarageAccuracyText = " Средняя точность: \(String(format: "%.2F", statisticService.totalAccuracy))%"
        
        let message = [gamesCountText, yourResultText, recordText].compactMap { $0 }.joined(separator: "\n")

        return message
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount {
            playedQuizes += 1
            let resultText = generateResultText()
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: resultText,
                buttonText: "Сыграть ещё раз")
            statisticService.store(correct: correctAnswers, total: questionsAmount)
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
            self.currentQuestionIndex = 0
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
    
    
    //MARK: - IBActions
    
    @IBAction func yesButtonClicked(_ sender: Any) {
        isAnswerCorrect(answer: true)
    }
    
    @IBAction func noButtonClicked(_ sender: Any) {
        isAnswerCorrect(answer: false)
    }
}

// MARK: - QuestionFactoryDelegate

extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}

fileprivate struct Constants {
    static let cornerRadius: CGFloat = 20
    static let borderWidth: CGFloat = 8
}
