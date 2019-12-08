//
//  LoginViewController.swift
//  SearchingAppDemo
//
//  Created by Kriti on 12/03/18.
//  Copyright © 2018 Demo. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var txtfEmail: UITextField!
    @IBOutlet var txtfPassword: UITextField!
    @IBOutlet var btnLogin: UIButton!
    var dataArray = [String]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
         self.setUpUi()
    }
    
    func setUpUi()
    {
        txtfEmail.text = ""
        txtfPassword.text = ""
        self.navigationController?.isNavigationBarHidden = true
        btnLogin.layer.cornerRadius = 5.0
    }
    
    @IBAction func actionRegisterButton(_ sender: Any)
    {
        let registerVC = self.storyboard?.instantiateViewController(withIdentifier: "RegistrationViewController") as! RegistrationViewController
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @IBAction func actionLoginButton(_ sender: UIButton)
    {
        self.validateFields()
    }
    
    func validateFields()
    {
        if txtfEmail.text == ""
        {
            showAlertController(text: "Please enter email address.", controller: self)
        }
        else if txtfPassword.text == ""
        {
            showAlertController(text: "Please enter password.", controller: self)
        }
        else if validateEmail(enteredEmail: txtfEmail.text!) == false
        {
            showAlertController(text: "Please enter valid email address.", controller: self)
        }
        else if (txtfPassword.text?.count)! < 6
        {
            showAlertController(text: "Password should contain at least 6 charaters.", controller: self)
        }
        else
        {
            var dataEntryArray : NSArray!
            if UserDefaults.standard.object(forKey: "usersdataEntryArray") != nil
            {
                dataEntryArray = UserDefaults.standard.object(forKey: "usersdataEntryArray") as! NSArray
                let predicate = NSPredicate(format: "email == %@", txtfEmail.text!)
                let emailArray = dataEntryArray.filter { predicate.evaluate(with: $0) } as NSArray
                if emailArray.count > 0
                {
                    let passwordPredict = NSPredicate(format: "password == %@", txtfPassword.text!)
                    let passwordArray = emailArray.filter { passwordPredict.evaluate(with: $0) }
                    if passwordArray.count > 0
                    {
                        self.view.endEditing(true)
                        txtfEmail.text = ""
                        txtfPassword.text = ""
                        UserDefaults.standard.set(passwordArray[0], forKey: "loggedInUserData")
                        UserDefaults.standard.set(true, forKey: "userLoggedIn")
                        UserDefaults.standard.synchronize()
                        let listVC = self.storyboard?.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
                        self.navigationController?.pushViewController(listVC, animated: true)
                    }
                    else
                    {
                        showAlertController(text: "Password entered is wrong.Please check again.", controller: self)
                    }
                }
                else
                {
                    showAlertController(text: "Please register first.", controller: self)
                }
            }
        }
    }
}

func showAlertController(text : String , controller : UIViewController)
{
    let alert  = UIAlertController(title: "Alert", message: text, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
        
    }))
    controller.present(alert, animated: true, completion: nil)
}

func validateEmail(enteredEmail:String) -> Bool
{
    let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
    return emailPredicate.evaluate(with: enteredEmail)
}
