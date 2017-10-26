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
        reloadDataFromDB()
        
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath)

        // Configuration de la cellule pour afficher les contacts
        if let contactCell = cell as? ContactTableViewCell{
            if let lastName = persons[indexPath.row].lastName, let firstName = persons[indexPath.row].firstName {
                contactCell.nameLabel.text = lastName + " " + firstName     //On affiche juste le nom, un espace et le prénom
            }
        }
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = PersonDetailsViewController(nibName: nil, bundle: nil)
        controller.person = self.persons[indexPath.row]
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
        
        //Code pour plus tard
        /*controller.onDeleteUser = { (personToDelete) in
            self.persons = self.persons.filter(blabla)
        }*/
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
        self.reloadDataFromDB()
    }
}

extension ContactsTableViewController: PersonDetailsViewControllerDelegate{
    func deleteContact(){
        self.navigationController?.popViewController(animated: true)
        self.reloadDataFromDB()
    }
}

extension UIViewController {
    func appDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}

