//
//  RegistrationViewController.swift
//  SearchingAppDemo
//
//  Created by Kriti on 12/03/18.
//  Copyright © 2018 Demo. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController, UITextFieldDelegate
{
    
    @IBOutlet var btnRegister: UIButton!
    @IBOutlet var txtfArray : Array<UITextField>!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        btnRegister.layer.cornerRadius = 5.0
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
       if textField == txtfArray[0]
       {
            txtfArray[0].resignFirstResponder()
            txtfArray[1].becomeFirstResponder()
        }
       else  if textField == txtfArray[1]
       {
            txtfArray[1].resignFirstResponder()
            txtfArray[2].becomeFirstResponder()
        }
       else  if textField == txtfArray[2]
       {
            txtfArray[2].resignFirstResponder()
            txtfArray[3].becomeFirstResponder()
        }
       else  if textField == txtfArray[3]
       {
            txtfArray[3].resignFirstResponder()
            txtfArray[4].becomeFirstResponder()
        }
       else
       {
            txtfArray[4].resignFirstResponder()
            self.validateField()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let characterSet = CharacterSet.letters
        if textField == txtfArray[0] || textField == txtfArray[1]
        {
            if string.rangeOfCharacter(from: characterSet.inverted) != nil
            {
                return false
            }
        }
        return true
    }
    
    @IBAction func actionRegistrationButton(_ sender: UIButton)
    {
       self.validateField()
    }
    
    func validateField()
    {
        if txtfArray[0].text == ""
        {
            showAlertController(text: "First name is blank.", controller: self)
        }
        else if txtfArray[1].text == ""
        {
            showAlertController(text: "Last name is blank.", controller: self)
        }
        else if txtfArray[2].text == ""
        {
            showAlertController(text: "Email address is blank.", controller: self)
        }
        else if txtfArray[3].text == ""
        {
            showAlertController(text: "Password is blank.", controller: self)
        }
        else if txtfArray[4].text == ""
        {
            showAlertController(text: "Confirm Password is blank.", controller: self)
        }
        else if validateEmail(enteredEmail: txtfArray[2].text!) == false
        {
            showAlertController(text: "Please enter valid email.", controller: self)
        }
        else if (txtfArray[3].text?.count)! < 6 || (txtfArray[4].text?.count)! < 6
        {
            showAlertController(text: "Password should contain at least 6 charaters.", controller: self)
        }
        else if txtfArray[3].text != txtfArray[4].text
        {
            showAlertController(text: "Password and confirm password doesn't match.", controller: self)
        }
        else
        {
            let userDict = ["firstName" : txtfArray[0].text,"lastName" : txtfArray[1].text ,"email":txtfArray[2].text, "password" : txtfArray[3].text]
            var mutableArray = NSMutableArray()

            if UserDefaults.standard.object(forKey: "usersdataEntryArray") != nil
            {
                let dataEntryArray = UserDefaults.standard.object(forKey: "usersdataEntryArray") as! NSArray
                let emailPredicate = NSPredicate(format: "email == %@", txtfArray[2].text!)
                let resultArray = dataEntryArray.filter { emailPredicate.evaluate(with: $0) } as NSArray
                if resultArray.count == 0
                {
                    mutableArray = dataEntryArray.mutableCopy() as! NSMutableArray
                    mutableArray.add(userDict)
                }
                else
                {
                    showAlertController(text: "This user is already registered.", controller: self)
                    return
                }
            }
            else
            {
                mutableArray.add(userDict)
            }
            UserDefaults.standard.set(mutableArray, forKey: "usersdataEntryArray")
            UserDefaults.standard.set(true, forKey: "userLoggedIn")
            UserDefaults.standard.set(userDict, forKey: "loggedInUserData")
            UserDefaults.standard.synchronize()
            let listVC = self.storyboard?.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
            self.navigationController?.pushViewController(listVC, animated: true)
        }
    }
    
}

