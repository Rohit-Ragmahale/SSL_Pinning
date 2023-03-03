//
//  ViewController.swift
//  SSL-pinning-weather
//
//  Created by Rohit Ragmahale on 16/02/2023.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var dataLabel: UILabel!
    let dataProvider: DataManager = NetworkManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dataLabel.text = ""
    }

    @IBAction func userTappedButton(_ sender: Any) {
        dataProvider.getCityWeatherData { data, error in
            DispatchQueue.main.async {
                if let data = data {
                    self.dataLabel.text = "Temp: - \(String(describing: data.main.temp))\n \(Date.now)"
                    print("we got data - \( data.main.temp!)")
                } else {
                    self.dataLabel.text = "We got error, try again"
                }
            }
        }
    }
}

