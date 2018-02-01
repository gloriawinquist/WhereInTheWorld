//
//  ViewController.swift
//  WhereInTheWorld
//
//  Created by Gloria Winquist on 2/1/18.
//  Copyright © 2018 Gloria Winquist. All rights reserved.
//

import UIKit

class WhereInTheWorldViewController: UIViewController {
    
    @IBOutlet var playButton: UIButton!
    @IBOutlet var answerLabel: UILabel!
    
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
    
    var selectedCountry: String?

    @IBAction func handlePlayButtonTapped(_ sender: UIButton) {
        
        // Randomly select a country from the array and display it in the Answer Label
        let count = countries.count
        let index = Int(arc4random_uniform(UInt32(count)))
        selectedCountry = countries[index]
        answerLabel.text = selectedCountry
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

}

