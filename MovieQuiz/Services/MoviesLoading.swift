import Foundation

protocol MoviesLoading {
    func loadMovies(completion handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}
