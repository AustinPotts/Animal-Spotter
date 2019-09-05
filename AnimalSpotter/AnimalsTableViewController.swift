//
//  AnimalsTableViewController.swift
//  AnimalSpotter
//
//  Created by Austin Potts on 9/4/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AnimalsTableViewController: UITableViewController {

    
    let apiController = APIController()
    var animalNames: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if apiController.bearer == nil {
            
        performSegue(withIdentifier: "LoginViewModalSegue", sender: self)
             }
    }
    
    
    @IBAction func getAnimals(_ sender: Any) {
        apiController.getAllAnimalNames { (result) in
            do {
                let animalNames = try result.get()
                self.animalNames = animalNames
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } catch {
                NSLog("Error getting animal name: \(error)")
                
            }
        }
        
    }
    
    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return animalNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnimalCell", for: indexPath)
        
        cell.textLabel?.text = animalNames[indexPath.row]
        return cell
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginViewModalSegue" {
            if let loginVC = segue.destination as? LoginViewController{
                loginVC.apiController = apiController
            }
        } else if segue.identifier == "ShowAnimalDetail" {
            if let detailVC = segue.destination as? AnimalDetailViewController,
                let indexPath = tableView.indexPathForSelectedRow {
                detailVC.apiController = apiController
                detailVC.animalName = self.animalNames[indexPath.row]
                
            }
        }
    }
    

}
