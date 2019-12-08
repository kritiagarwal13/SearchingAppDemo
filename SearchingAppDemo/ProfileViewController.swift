//
//  ProfileViewController.swift
//  SearchingAppDemo
//
//  Created by Kriti on 18/03/18.
//  Copyright © 2018 Demo. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var btnLogout: UIButton!
    var userData = [String:String]()
    var userParkedPlaces = NSMutableArray()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.initialSetUp()
    }
    
    func initialSetUp()
    {
        userData = UserDefaults.standard.object(forKey: "loggedInUserData") as! [String : String]
        if  let userParkedArray = UserDefaults.standard.object(forKey: "usersParkedArray") as? NSMutableArray
        {
            let predicate = NSPredicate(format: "email == %@", userData["email"]! )
            let bookedPlaces = userParkedArray.filter { predicate.evaluate(with: $0) }
            if bookedPlaces.count > 0
            {
                let bookedPlacesDict = bookedPlaces[0] as! NSDictionary
                userParkedPlaces = bookedPlacesDict["parkingArray"] as! NSMutableArray
            }
        }
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 1))
        self.btnLogout.layer.cornerRadius = 5.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            return 3
        }
       return userParkedPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath)
        if indexPath.section == 0
        {
            switch indexPath.row
            {
            case 0:
                cell.textLabel?.text = "First Name"
                cell.detailTextLabel?.text = userData["firstName"]
                break
            case 1:
                cell.textLabel?.text = "Last Name"
                cell.detailTextLabel?.text = userData["lastName"]
                break
            case 2:
                cell.textLabel?.text = "Email Address"
                cell.detailTextLabel?.text = userData["email"]
                break
            default:
                break
            }
        }
        else
        {
            let dict = userParkedPlaces[indexPath.row] as! NSDictionary
            cell.textLabel?.text = dict["place"] as? String
            cell.detailTextLabel?.text = "click to display"
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if section == 1 && userParkedPlaces.count > 0
        {
            return 40
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == 1 && userParkedPlaces.count > 0
        {
            return "Booked places by user"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let dict = userParkedPlaces[indexPath.row]
        let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        mapVC.placeDict = dict as! NSDictionary
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func actionLogoutButton(_ sender: Any)
    {
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
        UserDefaults.standard.removeObject(forKey: "loggedInUserData")
        UserDefaults.standard.removeObject(forKey: "placesArray")
        UserDefaults.standard.synchronize()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let navigationVC = UINavigationController(rootViewController: loginVC)
        AppDelegate.shared.window?.rootViewController = navigationVC
        AppDelegate.shared.window?.makeKeyAndVisible()
    }
    
}
