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
            //context.delete(self.person!)
            //try? context.save
            
            self.deletePersonOnDB()
            
            self.delegate?.deleteContact()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        //On affiche l'alert
        self.present(alertController, animated: true) {}
    }
    
    func deletePersonOnDB() {
        guard let id = self.person?.id else {
            return
        }
        var strId = String(id)
        
        let url = URL(string: "http://10.1.0.242:3000/persons/"+strId)!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        let context = self.appDelegate().persistentContainer.viewContext
        request.httpMethod = "DELETE"
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            
            let context = self.appDelegate().persistentContainer.viewContext
            context.delete(self.person!)
            
            do {
                if context.hasChanges {
                    try context.save()
                }
            } catch {
                print(error)
            }
        })
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
