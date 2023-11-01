import UIKit

protocol MovieQuizViewProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showAlert(quiz result: QuizResultsViewModel)
    func hideActivityIndicator()
    func showNetworkError(message: String)
    func highlightImageBorder(isCorrect: Bool)
    func resetImageSettings()
}

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private lazy var alertPresenter: AlertPresenterDelegate = {
        AlertPresenter(viewController: self)
    }()
    
    private var presenter: MovieQuizPresenterProtocol!
   
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(view: self)
        showLoadingIndicator()
    }
    
    //MARK: - private methods

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


extension MovieQuizViewController: MovieQuizViewProtocol {
    
    func highlightImageBorder(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = Constants.borderWidth
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = Constants.cornerRadius
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    func resetImageSettings() {
        self.imageView.layer.borderWidth = 0
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    func showAlert(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: presenter.generateResultText(),
            buttonText: "Сыграть ещё раз") { [ weak self ] in
                guard let self else { return }
                self.presenter.restartGame()
        }
        alertPresenter.presentAlert(with: alertModel)
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()        }
        alertPresenter.presentAlert(with: model)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func hideActivityIndicator() {
        activityIndicator.isHidden = true
    }
}

fileprivate struct Constants {
    static let cornerRadius: CGFloat = 20
    static let borderWidth: CGFloat = 8
}
