import Foundation

protocol MoviesLoading: AnyObject {
    func loadMovies(completion handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}
