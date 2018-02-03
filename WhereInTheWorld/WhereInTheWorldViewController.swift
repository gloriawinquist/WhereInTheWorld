//
//  ViewController.swift
//  WhereInTheWorld
//
//  Created by Gloria Winquist on 2/1/18.
//  Copyright © 2018 Gloria Winquist. All rights reserved.
//

import UIKit

// This app uses the flickr api to search for images of a given country and then have the user guess which country the image is from. Flickr api documentation can be found here: https://www.flickr.com/services/api/
let flickrApiKey = "51e35c229eb831ee98ec4530983f991c"

class WhereInTheWorldViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var answerButton: UIButton!
    @IBOutlet var label: UILabel!
    
    let flickrUrl = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=51e35c229eb831ee98ec4530983f991c&safe_search=1&content_type=1&media=photos&accuracy=3&geo_contest=2&per_page=1&page=1&format=json&nojsoncallback=1"
    
    let countries = [
        "Afghanistan",
        "Austria",
        "The Bahamas",
        "Belgium",
        "Brazil",
        "Canada",
        "Chile",
        "China",
        "Costa Rica",
        "Denmark",
        "Egypt",
        "Ethiopia",
        "Finland",
        "France",
        "Germany",
        "Greece",
        "Haiti",
        "Italy",
        "India",
        "Iran",
        "Ireland",
        "Jamaica",
        "Kazakhstan",
        "Kenya",
        "Lebanon",
        "Mexico",
        "Morocco",
        "New Zealand",
        "Nigeria",
        "Peru",
        "Portugal",
        "Russia",
        "Saudi Arabia",
        "Spain",
        "South Korea",
        "Sweden",
        "Switzerland",
        "Syria",
        "Thailand",
        "Uganda",
        "United Kingdom",
        "United States",
        "Venezuela",
        "Vatican City",
        "Zimbabwe"
    ]
    
    var selectedCountry = "United States"
    
    @IBAction func handlePlayButtonTapped(_ sender: UIButton) {
        
        // Disable play button, enable answer button
        playButton.isEnabled = false
        answerButton.isEnabled = true
        imageView.image = nil
        label.text = "Searching..."
        
        // Select a random country from the array to search for
        let count = countries.count
        let index = Int(arc4random_uniform(UInt32(count)))
        selectedCountry = countries[index]
        
        // Create the flickr url with the search term
        let searchUrl = flickrSearchUrl(for: selectedCountry)
        
        // Make the picture url request
        makePictureRequest(with: searchUrl)
    }
    
    @IBAction func handleAnswerButtonTapped(_ sender: UIButton) {
        
        // Enable play button, disable answer button
        playButton.isEnabled = true
        answerButton.isEnabled = false
        label.text = selectedCountry
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        answerButton.isEnabled = false
    }
    
    //MARK: - Private Methods
    
    /// Creates a flickr photo search url for a passed in search term
    ///
    /// - Parameter searchTerm: A String to search for
    /// - Returns: a flickr photo search url with the search term appended to it
    private func flickrSearchUrl(for searchTerm: String) -> String {
        guard let encodedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            print("Error: could not add percent encoding to \(searchTerm)")
            return flickrUrl
        }
        return flickrUrl + "&text=\(encodedSearchTerm)"
    }
    
    /// Makes the API call to flickr to search for photos with a passed in urlString
    ///
    /// - Parameter urlString: a formatted urlString for flickr photo search
    private func makePictureRequest(with urlString: String) {
        
        // 1.) Build a url with the urlString
        guard let url = URL(string: urlString) else {
            print("Error: Unable to create url with \(urlString)")
            return
        }
        
        // 2.) Create a request with the url
        let request = URLRequest(url: url)
        
        // 3.) Create a url session
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        // 4.) Create a dataTask on that session with the url request
        let dataTask = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let responseData = data, error == nil else {
                print("Something went wrong in fetching photos.")
                return
            }
            
            // 6.) Decode the responseData into a photo
            let decoder = JSONDecoder()
            do {
                let photoResponse = try decoder.decode(PhotoResponse.self, from: responseData)
                
                // 7.) Get the URL for the photo
                if let imageUrl = photoResponse.photos.photo.first?.imageUrl() {
                
                    // 8.) Pass to our method that will display the image
                    self?.displayImage(from: imageUrl)
                }
            }
            catch let jsonError {
                print("Error parsing JSON: \(jsonError)")
            }
        }
        // 5.) Resume (start) the dataTask to make the GET request
        dataTask.resume()
    }
    
    /// Displays the image for the passed in url in the imageView.
    ///
    /// - Parameter imageUrl: flickr url for an image
    private func displayImage(from imageUrl: URL) {
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let imageRequest = URLRequest(url: imageUrl)
        
        let imageTask = session.dataTask(with: imageRequest) { [weak self] (data, response, error) in
            guard let imageData = data, error == nil, let image = UIImage(data: imageData) else {
                print("Something went wrong in getting the image.")
                return
            }
            // All UI Updates must be done on the main thread - so you put them in this closure
            DispatchQueue.main.async {
                // Display image and change label text to be a question
                self?.imageView.image = image
                self?.label.text = "Where in the World is This?"
            }
        }
        imageTask.resume()
    }
}
