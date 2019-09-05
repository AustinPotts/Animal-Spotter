//
//  AnimalDetailViewController.swift
//  AnimalSpotter
//
//  Created by Austin Potts on 9/5/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AnimalDetailViewController: UIViewController {

    @IBOutlet weak var timeSeenLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var animalImageView: UIImageView!
    
    var apiController: APIController?
    var animalName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAnimal()
        
    }
    
    func getAnimal(){
        
        guard let animalName = animalName,
            let apiController = apiController else {return}
        
        apiController.getAnimal(with: animalName) { (result) in
            
            if let animal = try? result.get() {
                DispatchQueue.main.async {
                    self.updateViews(with: animal)
                }
            }
            
        }
        
    }
    
    func updateViews(with animal: Animal) {
        title = animal.name
        descriptionLabel.text = animal.description
        locationLabel.text = "lat: \(animal.latitude), long: \(animal.longitude)"
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        timeSeenLabel.text = df.string(from: animal.timeSeen)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
