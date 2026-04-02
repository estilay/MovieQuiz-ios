import Foundation

// MARK: - Protocol
protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

// MARK: - Movies Loader
struct MoviesLoader: MoviesLoading {
    // MARK: - Network Client
    private let networkClient: NetworkRouting
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to constuct mostPopularMoviesUrl")
        }
        return url
    }
    
    // MARK: - Public methods
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
