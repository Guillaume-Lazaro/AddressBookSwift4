//
//  AppDelegate.swift
//  AddressBookSwift4
//
//  Created by Guillaume Lazaro on 25/10/2017.
//  Copyright © 2017 Guillaume Lazaro. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "AddressBookSwift4")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    
    
    //Récupération des contacts du serveur:
    func makeGETCall() {
        let urlPath: String = "http://10.1.0.242:3000/persons"
        guard let url = URL(string: urlPath) else {
            return
        }
        
        //Création de la requete et de la tache pour récupérer les contacts de la bdd
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else {
                return
            }

            let dictionnary = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            guard let jsonDict = dictionnary as? [[String : Any]] else {
                return
            }
            
            self.updateFromJsonData(json: jsonDict)
        }
        task.resume()
    }
    
    func updateFromJsonData(json: [[String : Any ]]) {
        //Création de la requete pour mettre à jour à partir du fichiers json
        let sort = NSSortDescriptor(key: "id", ascending: true)
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        fetchRequest.sortDescriptors = [sort]
        
        let context = self.persistentContainer.viewContext
        let persons = try! context.fetch(fetchRequest)
        let personIds = persons.map({ (person) -> Int32 in
            return person.id
        })
        
        let serversid = json.map { (dict) -> Int in
            return dict["id"] as? Int ?? 0
        }
        
        //Suppression des data qui ne sont pas sur le serveur:
        for person in persons {
            if !serversid.contains(Int(person.id)) {
                context.delete(person)
            }
        }
        
        //Mise à jour ou création des personnes présente sur le serveur:
        for jsonPerson in json {
            let id = jsonPerson["id"] as? Int ?? 0
            if let index = personIds.index(of: Int32(id)) {
                persons[index].lastName = jsonPerson["lastname"] as? String ?? "ERROR"
                persons[index].firstName = jsonPerson["surname"] as? String ?? "ERROR"
                persons[index].avatarUrl = jsonPerson["pictureUrl"] as? String ?? "ERROR"
            } else {
                let person = Person(context: context)
                person.lastName = jsonPerson["lastname"] as? String
                person.firstName = jsonPerson["surname"] as? String
                person.avatarUrl = jsonPerson["pictureUrl"] as? String
                person.id = Int32(id)
            }
        }
        
        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            print(error)
        }
    }

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension UIViewController {
    func appDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}
