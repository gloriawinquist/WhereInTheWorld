//
//  Photo.swift
//  WhereInTheWorld
//
//  Created by Gloria Winquist on 2/3/18.
//  Copyright © 2018 Gloria Winquist. All rights reserved.
//

import Foundation

/// The root level object returned from a flickr photo search
/// Documentation is here: https://www.flickr.com/services/api/explore/flickr.photos.search
struct PhotoResponse: Decodable {
    let photos: PhotoPage
}

/// The mid level object that comes back in the `photos` field of the PhotoResponse and contains an array of Photo objects called `photo`
struct PhotoPage: Decodable {
    let photo: [Photo]
}

/// The object of photo information that can be turned into an imageUrl to retrieve a given photo
struct Photo: Decodable {
    
    let id: String
    let farm: Int
    let server: String
    let secret: String
    let title: String?
    
    /// Creates a staticflickr.com url for the photo per the documentation found at https://www.flickr.com/services/api/misc.urls.html
    ///
    /// - Returns: the url if it exists
    func imageUrl() -> URL? {
        let urlString = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
        return URL(string: urlString)
    }
}
