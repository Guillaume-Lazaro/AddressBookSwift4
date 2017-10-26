//
//  PersonDetailsViewController.swift
//  AddressBookSwift4
//
//  Created by Guillaume Lazaro on 25/10/2017.
//  Copyright © 2017 Guillaume Lazaro. All rights reserved.
//

import UIKit

class PersonDetailsViewController: UIViewController {

    
    
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    
    weak var person: Person?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func didPressDelete(_ sender: Any) {
        let alertController = UIAlertController(title: "Supprimer ?", message: "Êtes-vous sur de vouloir supprimer?", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Non", style: .cancel) { (action) in
            print("Non merci")
        }
        
        let deleteAction = UIAlertAction(title: "Oui", style: .default) { _ in //(action) = action = _
            self.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        self.present(alertController, animated: true) {
            print("Present?")
        }
        
        /*
         guard ....
         
         onDeleteUser(person!)
         */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
