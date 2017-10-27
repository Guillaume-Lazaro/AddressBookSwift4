import UIKit

protocol PersonDetailsViewControllerDelegate: AnyObject {
    func deleteContact()
}

class PersonDetailsViewController: UIViewController {

    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var picutreImageView: UIImageView!
    
    weak var person: Person?
    weak var delegate: PersonDetailsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Affichage:
        firstNameLabel.text = person?.firstName
        lastNameLabel.text = person?.lastName
        displayImage()
    }
    
    func displayImage() {
        //Récupération et affichage de l'image de l'avatar
        let strUrl = person?.avatarUrl ?? "https://vignette.wikia.nocookie.net/fallout/images/c/c3/Fallout3e.jpg/revision/latest/scale-to-width-down/160?cb=20090201113849"
        let url = URL(string: strUrl)
        let data = try? Data(contentsOf: url!)
        picutreImageView.image = UIImage(data: data!)
    }

    @IBAction func didPressDelete(_ sender: Any) {
        //Création de l'alert pour confirmer la suppression:
        let alertController = UIAlertController(title: "Supprimer ?", message: "Êtes-vous sur de vouloir supprimer?", preferredStyle: UIAlertControllerStyle.alert)
        
        //1 bouton cancel & 1 bouton valider
        let cancelAction = UIAlertAction(title: "Non", style: .cancel) { _ in
            print("Non merci")
        }
        
        let deleteAction = UIAlertAction(title: "Oui", style: .default) { _ in
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
        
        let strId = String(id)
        let url = URL(string: "http://10.1.0.242:3000/persons/"+strId)!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        let context = self.appDelegate().persistentContainer.viewContext
        request.httpMethod = "DELETE"
        
        //Tache pour supprimer la person avec l'id correspondant:
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
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
