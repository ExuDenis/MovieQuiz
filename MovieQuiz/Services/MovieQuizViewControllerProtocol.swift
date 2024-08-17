//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Денис Филатов on 15.08.2024.
//
import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func setButtonsEnabled(_ isEnabled: Bool)
    func showAnswerResult(isCorrect: Bool)
    func resetImageBorder()
    func hideActivityIndicator()
}
