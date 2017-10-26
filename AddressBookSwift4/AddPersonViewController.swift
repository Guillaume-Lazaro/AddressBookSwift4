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
            self.delegate?.addContact(lastName: lastNameEntered, firstName: firstNameEntered)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
