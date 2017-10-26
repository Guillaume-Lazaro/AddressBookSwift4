import UIKit
import CoreData

class ContactsTableViewController: UITableViewController {

    var persons = [Person]()
    
    weak var delegate: AddContactDelegate?
    
    func reloadDataFromDB() {
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
        
        /*
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
                
        //Neew V3.0
        //reloadDataFromDB()
        
        //New appel serveur
        appDelegate().makeGETCall()
        
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        let sortFirstName = NSSortDescriptor(key: "firstName", ascending: true)
        let sortLastName = NSSortDescriptor(key: "lastName", ascending: true)
        fetchRequest.sortDescriptors = [sortFirstName,sortLastName]
        
        
        resultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.appDelegate().persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        resultController.delegate = self
        
        try? resultController.performFetch()
        ///////
        
        //Bouton pour ajouter un contact
        let addContact = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContactPress))
        self.navigationItem.rightBarButtonItem = addContact
        
        //Message de bienvenue :
        if let value = UserDefaults.standard.value(forKey: "isFirstTime") {
            print("Nope")
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
        
        guard let object = self.resultController?.object(at: indexPath) else {
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
        controller.person = self.persons[indexPath.row] //TODO fix it
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
        
        //Code pour plus tard
        /*controller.onDeleteUser = { (personToDelete) in
            self.persons = self.persons.filter(blabla)
        }*/
    }
}

extension ContactsTableViewController: AddContactDelegate {
    func addContact(lastName: String, firstName: String) {
        let context = appDelegate().persistentContainer.viewContext
        let person = Person(entity: Person.entity(), insertInto: context)
        person.firstName = firstName
        person.lastName = lastName
        
        do {
            try context.save()
        } catch {
            print("Erreur : "+error.localizedDescription)
        }
        
        self.navigationController?.popViewController(animated: true)
        //self.reloadDataFromDB()
    }
}

extension ContactsTableViewController: PersonDetailsViewControllerDelegate{
    func deleteContact(){
        self.navigationController?.popViewController(animated: true)
        //self.reloadDataFromDB()
    }
}

extension UIViewController {
    func appDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
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

