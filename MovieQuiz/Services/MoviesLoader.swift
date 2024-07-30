import Foundation

protocol MoviesLoading {
    func loadMovies(completion handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}
final class MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    private let networkClient = NetworkClient()
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        // Если мы не смогли преобразовать строку в URL, то приложение упадёт с ошибкой
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }

    func loadMovies(completion handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    print("Movies loaded successfully: \(mostPopularMovies)")
                    handler(.success(mostPopularMovies))
                } catch {
                    print("Failed to decode movies: \(error)")
                    handler(.failure(error))
                }
            case .failure(let error):
                print("Failed to load movies: \(error)")
                handler(.failure(error))
            }
        }
    }
}


