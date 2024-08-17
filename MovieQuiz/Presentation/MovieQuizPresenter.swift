//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Денис Филатов on 11.08.2024.
//

import UIKit
final class MovieQuizPresenter: QuestionFactoryDelegate {
    let questionsAmount: Int = 10
    var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticServiceProtocol!
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewControllerProtocol?
    var alertPresenter = AlertPresenter()
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        let moviesLoader = MoviesLoader()
        questionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: self)
        statisticService = StatisticService()
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image: UIImage
        switch model.image {
        case .data(let data):
            image = UIImage(data: data) ?? UIImage()
        case .string(_):
            image = UIImage()
        }
        return QuizStepViewModel(
            image: image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func changeStateButton(isEnabled: Bool) {
        viewController?.setButtonsEnabled(isEnabled)
    }
    func yesButtonClicked(_ sender: Any) {
        didAnswer(isYes: true)
        changeStateButton(isEnabled: false)
    }
    
    func noButtonClicked(_ sender: Any) {
        didAnswer(isYes: false)
        changeStateButton(isEnabled: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)

        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.proceedToNextQuestionOrResults()
            self.viewController?.resetImageBorder()
            self.changeStateButton(isEnabled: true)
            
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let text = correctAnswers == questionsAmount ?
            "Поздравляем, вы ответили на 10/10!":
            "Ваш результат: \(correctAnswers)/10"
            let gamesCount = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let bestGame = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))"
            let averageAccuracy = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            let finalText = "\(text)\n\(gamesCount)\n\(bestGame)\n\(averageAccuracy)"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: finalText,
                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    //MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideActivityIndicator() // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
}



