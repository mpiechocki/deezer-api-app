import Combine
import Foundation
@testable import deezer_api_app

class DataTaskProviderSpy: DataTaskProvider {

    var stubbedTaskSubject =  PassthroughSubject<URLSession.DataTaskPublisher.Output, URLError>()

    var dataTaskPublisherCalledWith: [URL] = []

    // MARK: - DataTaskProvider

    func taskPublisher(for url: URL) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLError> {
        dataTaskPublisherCalledWith.append(url)

        return stubbedTaskSubject.eraseToAnyPublisher()
    }

}
