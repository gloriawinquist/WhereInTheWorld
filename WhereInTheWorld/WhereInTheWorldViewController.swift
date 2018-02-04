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

class WhereInTheWorldViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var label: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var myScoreLabel: UILabel!
    @IBOutlet var highScoreLabel: UILabel!
    
    let flickrUrl = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=51e35c229eb831ee98ec4530983f991c&safe_search=1&content_type=1&media=photos&accuracy=3&geo_contest=2&in_gallery=1&per_page=500&page=1&format=json&nojsoncallback=1"
    
    let countries = [
        "Afghanistan",
        "Albania",
        "Algeria",
        "Angola",
        "Argentina",
        "Australia",
        "Austria",
        "The Bahamas",
        "Belgium",
        "Botswana",
        "Brazil",
        "Bulgaria",
        "Canada",
        "Chile",
        "China",
        "Costa Rica",
        "Cuba",
        "Denmark",
        "Dominican Republic",
        "Egypt",
        "Ethiopia",
        "Finland",
        "France",
        "Germany",
        "Greece",
        "Guatemala",
        "Haiti",
        "Hong Kong",
        "Iceland",
        "India",
        "Iran",
        "Iraq",
        "Ireland",
        "Israel",
        "Italy",
        "Jamaica",
        "Japan",
        "Kazakhstan",
        "Kenya",
        "Lebanon",
        "Libya",
        "Mexico",
        "Morocco",
        "Netherlands",
        "New Zealand",
        "Nigeria",
        "North Korea",
        "Norway",
        "Pakistan",
        "Peru",
        "Poland",
        "Portugal",
        "Russia",
        "Rwanda",
        "Spain",
        "South Korea",
        "Sweden",
        "Switzerland",
        "Thailand",
        "Uganda",
        "United Kingdom",
        "United States",
        "Venezuela",
        "Vatican City",
        "Zimbabwe"
    ]
    
    let numberOfQuestions = 20
    var question = 0
    var score = 0
    var highScore = 0
    
    var remainingCountries: [String] = []
    
    // when true, we show the correct country in green and a wrong guess in red in the tableview
    var shouldShowAnswer = false
    
    var selectedCountry = "United States"
    var guessedCountry: String?
    
    // array of four random coutries (including selected country) to display as multiple choice selection
    var guesses: [String] = []
    
    var images: [UIImage] = []
    var imageIndex = 0
    
    @IBAction func handlePlayButtonTapped(_ sender: UIButton) {
        
        // Disable play button, enable answer button
        playButton.isEnabled = false
        tableView.isHidden = true
        shouldShowAnswer = false
        guessedCountry = nil
        imageView.image = nil
        label.text = "Searching..."
        images.removeAll()
        guesses.removeAll()
        imageIndex = 0
        
        // Select a random country from the array to search for
        let count = remainingCountries.count
        let index = Int(arc4random_uniform(UInt32(count)))
        // This time remove the country from the array so that it does not appear again in the quiz
        selectedCountry = remainingCountries.remove(at: index)
        
        // Create the flickr url with the search term
        let searchUrl = flickrSearchUrl(for: selectedCountry)
        
        // Make the picture url request
        makePictureRequest(with: searchUrl)
        
        // Create the guesses array of countries
        // a SET can only contain unique elements
        var uniqueGuesses = Set<String>()
        uniqueGuesses.insert(selectedCountry)
        
        // keep trying to add a random member of countries to unique guesses until there are 4 guesses
        while uniqueGuesses.count < 4 {
            let randomIndex = Int(arc4random_uniform(UInt32(count)))
            uniqueGuesses.insert(countries[randomIndex])
        }
        guesses = Array(uniqueGuesses)
        tableView.reloadData()
        tableView.isUserInteractionEnabled = true
    }
    
    @IBAction func handlePictureTapped(_ sender: UITapGestureRecognizer) {
        
        // show the next picture in the array
        imageIndex += 1
        
        // when the image index gets to the end of the array, set it back to 0
        if imageIndex >= images.count {
            imageIndex = 0
        }
        
        // always check that your imageIndex is not out of bounds of the array to prevent a crash
        if images.count > imageIndex {
            imageView.image = images[imageIndex]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        remainingCountries = countries
        tableView.isHidden = true
        getHighScore()
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
                
                // 7.) Get the URL for each photo and add each image to the image array
                var shouldDisplayPhoto = true
                
                // Let's mix it up! Get 5 random photos instead of the same 5 every time
                for _ in 1...5 {
                    // Select a random photo from the photos that were returned
                    let count = photoResponse.photos.photo.count
                    let index = Int(arc4random_uniform(UInt32(count)))
                    let photo = photoResponse.photos.photo[index]
                    
                    if let imageUrl = photo.imageUrl() {
                        
                        // 8.) Pass to our method that will fetch the image and then add it to our images array
                        // only display the first photo
                        self?.fetchImage(from: imageUrl, display: shouldDisplayPhoto)
                        shouldDisplayPhoto = false
                    }
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
    private func fetchImage(from imageUrl: URL, display: Bool) {
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let imageRequest = URLRequest(url: imageUrl)
        
        let imageTask = session.dataTask(with: imageRequest) { [weak self] (data, response, error) in
            guard let imageData = data, error == nil, let image = UIImage(data: imageData) else {
                print("Something went wrong in getting the image.")
                return
            }
            self?.images.append(image)
            // All UI Updates must be done on the main thread - so you put them in this closure
            DispatchQueue.main.async {
                // Change label text to be a question
                self?.label.text = "Where in the World is This?"
                // Display image if its the first one
                if display {
                    self?.imageView.image = image
                    self?.tableView.isHidden = false
                }
            }
        }
        imageTask.resume()
    }
    
    private func gameOver() {
        // display score
        label.text = "You got \(score) out of \(numberOfQuestions)!!!"
        playButton.setTitle("Play Again", for: .normal)
        
        // reset state
        question = 0
        score = 0
        remainingCountries = countries
    }
    
    private func getHighScore() {
        let defaults = UserDefaults.standard
        if let theHighScore = defaults.object(forKey: "highScore") as? Int {
            highScore = theHighScore
        }
        highScoreLabel.text = "High Score: \(highScore)"
    }
    
    private func setNewHighScore(_ score: Int) {
        let defaults = UserDefaults.standard
        defaults.set(score, forKey: "highScore")
        defaults.synchronize()
        highScoreLabel.text = "High Score: \(score)"
    }
    
    //MARK: - UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countrySelectionCellIdentifier", for: indexPath)
        
        // reset the background color of the cells to white and the text to dark
        cell.backgroundColor = .white
        cell.textLabel?.textColor = .darkText
        
        if guesses.count > indexPath.row {
            
            let guess = guesses[indexPath.row]
            cell.textLabel?.text = guess
            
            if shouldShowAnswer {
                if guess == selectedCountry {
                    cell.backgroundColor = .green
                    cell.textLabel?.textColor = .white
                } else if guess == guessedCountry {
                    cell.backgroundColor = .red
                    cell.textLabel?.textColor = .white
                }
            }
        }
        return cell
    }
    
    //MARK: - UITableViewDelegate Methods
    
    // set the guessed country and then reload the table to show the correct answer
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if guesses.count > indexPath.row {
            guessedCountry = guesses[indexPath.row]
        }
        
        // Track the score
        if guessedCountry == selectedCountry {
            label.text = "Congratulations! You got the right answer!"
            score += 1
            myScoreLabel.text = "Score: \(score)"
            if score > highScore {
                setNewHighScore(score)
            }
        } else {
            label.text = "Wrong answer. Better luck next time."
        }
        
        shouldShowAnswer = true
        tableView.reloadData()
        tableView.isUserInteractionEnabled = false
        playButton.isEnabled = true
        question += 1
        
        // Check and see if the game has ended
        if question == numberOfQuestions {
            gameOver()
        } else {
            playButton.setTitle("Next", for: .normal)
        }
    }
}
