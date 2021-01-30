@testable import deezer_api_app

extension Array where Element == Track {

    static var stubbedTracks: [Track] {
        [
            Track(title: "Second Hand News", duration: 90, trackPosition: 1),
            Track(title: "Dreams", duration: 180, trackPosition: 2),
            Track(title: "Never Going Back Again", duration: 431, trackPosition: 3)
        ]
    }

}
