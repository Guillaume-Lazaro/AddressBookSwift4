import UIKit

protocol PersonDetailsViewControllerDelegate: AnyObject {
    func deleteContact()
}

class PersonDetailsViewController: UIViewController {

    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    
    weak var person: Person?
    weak var delegate: PersonDetailsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func didPressDelete(_ sender: Any) {
        //Création de l'alert pour confirmer la suppression:
        let alertController = UIAlertController(title: "Supprimer ?", message: "Êtes-vous sur de vouloir supprimer?", preferredStyle: UIAlertControllerStyle.alert)
        
        //1 bouton cancel & 1 bouton valider
        let cancelAction = UIAlertAction(title: "Non", style: .cancel) { _ in
            print("Non merci")
        }
        
        let deleteAction = UIAlertAction(title: "Oui", style: .default) { _ in
            let context = self.appDelegate().persistentContainer.viewContext    //récupération de la db
            
            /*if let personToDelete = self.person {
                context.delete(personToDelete)
            }*/
            context.delete(self.person!)        //On supprimer la personne..
            try? context.save                   //.. et on sauvegarde les modifications
            self.delegate?.deleteContact()
        }
        
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        //On affiche l'alert
        self.present(alertController, animated: true) {}
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
