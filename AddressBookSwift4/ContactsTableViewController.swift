import UIKit
import CoreData

class ContactsTableViewController: UITableViewController {

    var persons = [Person]()
    
    weak var delegate: AddContactDelegate?
    
    func reloadDataFromDB() {
        //Récupération des data:
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        let sortFirstName = NSSortDescriptor(key: "firstName", ascending: true)
        let sortLastName = NSSortDescriptor(key: "lastName", ascending: true)
        fetchRequest.sortDescriptors = [sortFirstName,sortLastName]
        
        let context = self.appDelegate().persistentContainer.viewContext
        guard let personsDB = try? context.fetch(fetchRequest) else {return}
        persons = personsDB
        self.tableView.reloadData()
    }
    
    var resultController: NSFetchedResultsController<Person>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Ancien code permettant de récupérer des utilisateurs à partir d'un fichier plist
        let namesPlist = Bundle.main.path(forResource: "names.plist", ofType:nil)
        if let namesPath = namesPlist {
            let url = URL(fileURLWithPath: namesPath)
            let dataArray = NSArray(contentsOf: url)
            
            for dict in dataArray! {
                if let dictionnary = dict as? [String:String] {
                    let person = Person(lastName: dictionnary["lastname"]!, firstName: dictionnary["name"]!)
                    print(dictionnary)
                    persons.append(person)
                }
            }
        }*/
        
        //Initialisation du titre et de la liste
        self.title = "Mes Contacts"
        appDelegate().makeGETCall()
        
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        let sortFirstName = NSSortDescriptor(key: "firstName", ascending: true)
        let sortLastName = NSSortDescriptor(key: "lastName", ascending: true)
        fetchRequest.sortDescriptors = [sortFirstName,sortLastName]
        
        //Nouvelle version: utilisation d'un fetched result controller
        resultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.appDelegate().persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        resultController.delegate = self
        
        try? resultController.performFetch()
        
        //Bouton pour ajouter un contact
        let addContact = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContactPress))
        self.navigationItem.rightBarButtonItem = addContact
        
        //Message de bienvenue :
        if UserDefaults.standard.value(forKey: "isFirstTime") != nil {
            print("It's not the first time")
        } else {
            UserDefaults.standard.set(false, forKey: "isFirstTime")
            
            let alertController = UIAlertController(title: "Bienvenue", message: "Bienvenue dans cette superbe application de test !", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cool", style: .cancel) { (action) in
                print("Cool")
            }
            
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true) {}
        }
    }

    @objc func addContactPress() {
        //Création du controller pour l'ajout et du delegate
        let controller = AddPersonViewController(nibName: nil, bundle: nil)
        self.navigationController?.pushViewController(controller, animated: true)
        
        controller.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if let frc = resultController {
            return frc.sections!.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.resultController?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath)
        
        guard (self.resultController?.object(at: indexPath)) != nil else {
            fatalError("Attempt to configure cell without a managed object")
        }
        
        // Configuration de la cellule pour afficher les contacts
        if let contactCell = cell as? ContactTableViewCell{
            if let person = self.resultController?.object(at: indexPath) {
                if let lastName = person.lastName, let firstName = person.firstName {
                    contactCell.nameLabel.text = lastName + " " + firstName     //On affiche juste le nom, un espace et le prénom
                }
            }
        }
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = PersonDetailsViewController(nibName: nil, bundle: nil)
        controller.person = self.resultController?.object(at: indexPath)
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension ContactsTableViewController: AddContactDelegate {
    func addContact(lastName: String, firstName: String) {        
        self.navigationController?.popViewController(animated: true)
    }
}

extension ContactsTableViewController: PersonDetailsViewControllerDelegate{
    func deleteContact(){
        self.navigationController?.popViewController(animated: true)
        //self.reloadDataFromDB() //Obsoléte
    }
}

extension ContactsTableViewController : NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = resultController?.sections?[section] else {
            return nil
        }
        return sectionInfo.name
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return resultController?.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        guard let result = resultController?.section(forSectionIndexTitle: title, at: index) else {
            fatalError("Unable to locate section for \(title) at index: \(index)")
        }
        return result
    }
}

