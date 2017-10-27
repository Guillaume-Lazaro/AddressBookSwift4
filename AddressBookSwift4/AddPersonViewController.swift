import UIKit

protocol AddContactDelegate: AnyObject {
    func addContact(lastName: String, firstName: String)
}

class AddPersonViewController: UIViewController {
    
    
    @IBOutlet weak var progressBarAdd: UIProgressView!
    
    @IBOutlet weak var PersonTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    
    weak var delegate: AddContactDelegate?
    
    @IBAction func didPressValid(_ sender: Any) {
        if let lastNameEntered = PersonTextField.text, let firstNameEntered = firstNameTextField.text {
            addContactOnDB()
            self.delegate?.addContact(lastName: lastNameEntered, firstName: firstNameEntered) //OLD
            //fillProgressBar() //Bon ça c'est rigolo mais pas très utile
        }
    }
    
    func fillProgressBar() {
        var progress: Float = 0
        
        DispatchQueue.global(qos: .userInteractive).async {
            while(progress<1) {
                Thread.sleep(forTimeInterval: 0.1)
                progress += 0.1
                
                print(progress)
                DispatchQueue.main.async {
                    self.progressBarAdd.setProgress(progress, animated: true)
                }
            }
            DispatchQueue.main.async {
                self.addPerson()
            }
        }
    }
    
    func addPerson() {
        if let lastNameEntered = PersonTextField.text, let firstNameEntered = firstNameTextField.text {
            self.delegate?.addContact(lastName: lastNameEntered, firstName: firstNameEntered)
        }
    }
    
    func addContactOnDB() {
        var json = [String:String]()
        json["lastname"] = self.PersonTextField.text ?? "unknown"
        json["surname"] = self.firstNameTextField.text ?? "unknown"
        json["pictureUrl"] = "https://vignette.wikia.nocookie.net/fallout/images/c/c3/Fallout3e.jpg/revision/latest/scale-to-width-down/160?cb=20090201113849"
        
        let url = URL(string: "http://10.1.0.242:3000/persons")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        let context = self.appDelegate().persistentContainer.viewContext
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        } catch {
            print(error)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    let person = Person(entity: Person.entity(), insertInto: context)
                    person.lastName = jsonDict["lastname"] as? String
                    person.firstName = jsonDict["surname"] as? String
                    person.avatarUrl = jsonDict["pictureUrl"] as? String
                    person.id = Int32(jsonDict["id"] as? Int ?? 0)
                    
                    do {
                        if context.hasChanges {
                            try context.save()
                        }
                    } catch {
                        print(error)
                    }
                }
            } catch {
                print(error)
            }
        })
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

