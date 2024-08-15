import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    //MARK: - IB Outlets
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked(UIButton())
    }
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked(UIButton())
    }
    
    // MARK: - Variables
    private var presenter: MovieQuizPresenter! = nil
    private var alertPresenter: AlertPresenter?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter()
        activityIndicator.hidesWhenStopped = true
    }
    
    // MARK: - Private functions
    func hideActivityIndicator() {
        activityIndicator.isHidden = true
    }
    
    func resetImageBorder() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
    }
    
    func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func showAnswerResult(isCorrect: Bool) {
        presenter.proceedWithAnswer(isCorrect: isCorrect)
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                self.presenter.restartGame()
                self.presenter.questionFactory?.requestNextQuestion()
            })
        alertPresenter?.show(from: self, with: alertModel)
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
     func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
            self.presenter.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.show(from: self, with: model)
    }
}
