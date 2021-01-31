enum Route: Equatable {
    case search
    case albums(title: String, artistId: Int)
    case albumDetails(albumDetails: AlbumDetails)
}
