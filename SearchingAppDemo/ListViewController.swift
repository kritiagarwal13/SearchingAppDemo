//
//  ListViewController.swift
//  SearchingAppDemo
//
//  Created by Kriti on 13/03/18.
//  Copyright © 2018 Demo. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var lblSearchPlace: UILabel!
    var placesArray = NSMutableArray()
    var searchedResultArray = [[String : Any]]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.setUpData()
        self.setUpUi()
    }
    
    func setUpData()
    {
        if UserDefaults.standard.object(forKey: "placesArray") == nil
        {
            placesArray = [["place" : "Rjouri Garden Metro Station", "lat" : 28.649004, "lng" : 77.122635, "parkingAvailable" : true],["place" : "Subhash Nagar", "lat" : 28.64043, "lng" : 77.104904, "parkingAvailable" : true],["place" : "Saket Metro station", "lat" : 28.5205, "lng" : 77.2016, "parkingAvailable" : true],["place" : "Gurgaon Ambience Mall", "lat" : 28.5043, "lng" : 77.0965, "parkingAvailable" : true],["place" : "Tilak Nagar", "lat" : 28.65725, "lng" : 77.09685, "parkingAvailable" : true],["place" : "Noida City Center", "lat" : 28.5748, "lng" : 77.3562, "parkingAvailable" : true],["place" : "Cannaught Place", "lat" : 28.6328, "lng" : 77.2197, "parkingAvailable" : true],["place" : "Janak Puri", "lat" : 28.6296, "lng" : 77.0802, "parkingAvailable" : true],["place" : "Malviya Nagar", "lat" : 28.5335, "lng" : 77.2109, "parkingAvailable" : true],["place" : "Hauz Khas", "lat" : 28.555, "lng" : 77.1916, "parkingAvailable" : true],["place" : "Chandni Chawk", "lat" : 28.6506, "lng" : 77.2319, "parkingAvailable" : true],["place" : "Select City Walk", "lat" : 28.5281, "lng" : 77.2182, "parkingAvailable" : true],["place" : "Tagore Garden", "lat" : 28.6469, "lng" : 77.1101, "parkingAvailable" : true]]
            UserDefaults.standard.set(placesArray, forKey: "placesArray")
            UserDefaults.standard.synchronize()
        }
        else
        {
            placesArray = (UserDefaults.standard.object(forKey: "placesArray") as! NSArray).mutableCopy() as! NSMutableArray
        }
    }
    
    func setUpUi()
    {
        self.navigationController?.isNavigationBarHidden = false
        self.title = "Search Place"
        self.navigationItem.hidesBackButton = true
        self.searchedResultArray = [[String : Any]]()
        self.searchBar.text = ""
        let btnLogout = UIButton(type: .custom)
        btnLogout.frame = CGRect(x: 0, y: 0, width: 80, height: 44)
        btnLogout.setTitleColor(UIColor.black, for: .normal)
        btnLogout.setTitle("Profile", for: .normal)
        btnLogout.addTarget(self, action: #selector(actionProfileButton(sender:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btnLogout)
    }
    
    @objc func actionProfileButton(sender : UIButton)
    {
        self.view.endEditing(true)
        let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    //MARK: Tableview DELEGATE & Datasource Methods--------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if searchBar.text != ""
        {
            return searchedResultArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let dict = searchedResultArray[indexPath.row] as NSDictionary
        cell.textLabel?.text = dict["place"] as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let dict = searchedResultArray[indexPath.row] as NSDictionary
        self.showAlertController(title : "Do you want to search parking at \(dict["place"] as! String)", dict: dict, secondAlert: false)
    }
    
    //MARK: SHOW ALERT METHOD ---------------
    func showAlertController(title : String , dict : NSDictionary, secondAlert : Bool )
    {
        let alertController = UIAlertController(title: "ALERT", message: title, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            if (dict["parkingAvailable"] as! Bool) == true && !secondAlert
            {
                self.showAlertController(title: "Congrats! You got your parking spot. Click Yes to see navigation", dict: dict, secondAlert: true)
            }
            else if (dict["parkingAvailable"] as! Bool) == true
            {
                let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
                let dataDict = dict.mutableCopy() as! NSDictionary
                dataDict.setValue(false, forKey: "parkingAvailable")
                let index = self.placesArray.index(of: dict)
                self.placesArray.replaceObject(at: index, with: dataDict)
                mapVC.placeDict = dataDict
                let userData = UserDefaults.standard.object(forKey: "loggedInUserData") as! [String : String]
                if  let userParkedArray = UserDefaults.standard.object(forKey: "usersParkedArray") as? NSArray
                {
                    let predicate = NSPredicate(format: "email == %@", userData["email"]! )
                    let bookedPlaces = userParkedArray.filter { predicate.evaluate(with: $0) }
                    if bookedPlaces.count > 0
                    {
                        let bookedPlacesDict = bookedPlaces[0] as! NSDictionary
                        let userPlacesArray = bookedPlacesDict["parkingArray"] as! NSArray
                        var dataArray = NSMutableArray()
                        dataArray = userPlacesArray.mutableCopy() as! NSMutableArray
                        dataArray.add(dataDict)
                        //userPlacesArray.adding(dataDict)
                        let userParkedData = ["email" : userData["email"] ?? "" ,"parkingArray" : dataArray] as [String : Any]
                        let index = userParkedArray.index(of: bookedPlacesDict)
                        let dataParkedArray = userParkedArray.mutableCopy() as! NSMutableArray
                        dataParkedArray.replaceObject(at: index, with: userParkedData)
                        UserDefaults.standard.set(dataParkedArray, forKey: "usersParkedArray")
                        UserDefaults.standard.synchronize()
                    }
                    else
                    {
                        var dataArray = NSMutableArray()
                        dataArray.add(dataDict)
                        let userParkedData = ["email" : userData["email"] ?? "" ,"parkingArray" : dataArray] as [String : Any]
                        dataArray = userParkedArray.mutableCopy() as! NSMutableArray
                        dataArray.add(userParkedData)
                        UserDefaults.standard.set(dataArray, forKey: "usersParkedArray")
                        UserDefaults.standard.synchronize()
                    }
                }
                else
                {
                    AppDelegate.shared.bookingArray.add(dict)
                    var dataArray = NSMutableArray()
                    dataArray.add(dataDict)
                    let userParkedData = ["email" : userData["email"] ?? "" ,"parkingArray" : dataArray] as [String : Any]
                    dataArray = NSMutableArray()
                    dataArray.add(userParkedData)
                    UserDefaults.standard.set(dataArray, forKey: "usersParkedArray")
                    UserDefaults.standard.synchronize()
                }                
                UserDefaults.standard.set(self.placesArray, forKey: "placesArray")
                UserDefaults.standard.synchronize()
                self.view.endEditing(true)
                self.navigationController?.pushViewController(mapVC, animated: true)
            }
            else
            {
                let alertController = UIAlertController(title: "ALERT", message: "Sorry! No parking available.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    
                }))
                self.present(alertController, animated: true, completion: nil)
            }
        }))
        alertController.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
            
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: SEARCHBAR DELEGATE METHODS ------------------
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
       searchBar.text = ""
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchBar.text == ""
        {
            lblSearchPlace.text = "Search Place To Find Parking."
            self.lblSearchPlace.isHidden = false
            self.tableView.isHidden = true
            searchedResultArray = [[String : Any]]()
        }
        else
        {
            let predicate = NSPredicate(format: "place contains[c] %@", searchBar.text!)
            searchedResultArray = placesArray.filter { predicate.evaluate(with: $0) } as! [[String : Any]]
            print(searchedResultArray)
            if searchedResultArray.count > 0
            {
                self.tableView.isHidden = false
                self.lblSearchPlace.isHidden = true
            }
            else
            {
                self.tableView.isHidden = true
                self.lblSearchPlace.isHidden = false
                self.lblSearchPlace.text = "No nearby place available."
            }
        }
        tableView.reloadData()
    }
   
}
