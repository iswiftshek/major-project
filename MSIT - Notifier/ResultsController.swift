//
//  ResultsController.swift
//  MSIT - Notifier
//
//  Created by Abhishek Sansanwal on 26/11/20.
//  Copyright © 2020 Verved. All rights reserved.
//

import UIKit
import WebKit
import SwiftSoup

class ResultsController: UIViewController, UITabBarDelegate, WKNavigationDelegate, UITextFieldDelegate {
    
    var activityIndicator: UIActivityIndicatorView!
    let webView = WKWebView()
    let closeButton = UIButton()
    let blur = UIBlurEffect(style: UIBlurEffect.Style.light)
    var blurView = UIVisualEffectView()
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBAction func buttonPressed(_ sender: Any) {
        view.addSubview(self.blurView)
        
        let linkURLFinal = URL(string: "https://www.ipuranklist.com/student/\(textField.text!)")!
        let request = URLRequest(url: linkURLFinal)
        webView.frame = CGRect(x: 0, y: 200, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-200)
        webView.load(request)
        view.addSubview(webView)
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray

        view.addSubview(activityIndicator)
        view.addSubview(closeButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        textField.delegate = self
        button.isEnabled = false
        blurView = UIVisualEffectView(effect: self.blur)
                  blurView.frame = self.view.bounds
                  webView.navigationDelegate = self
        closeButton.setImage(UIImage(named: "close"), for: .normal)
        closeButton.frame = CGRect(x: UIScreen.main.bounds.width/2 - 20, y: 100, width: 40, height: 40)
        closeButton.addTarget(self, action: #selector(pressed), for: .touchUpInside)
    }
    
    let defaultSession = URLSession(configuration: .default)
         var dataTask: URLSessionDataTask?
         
         @objc func pressed(sender: UIButton!) {
             self.webView.removeFromSuperview()
             self.closeButton.removeFromSuperview()
             self.activityIndicator.removeFromSuperview()
             self.blurView.removeFromSuperview()
         }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""

        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.count >= 11 {
            button.isEnabled = true
            if #available(iOS 13.0, *) {
                button.backgroundColor = .link
            } else {
                button.backgroundColor = .blue
            }
        }
        else {
            button.isEnabled = false
            if #available(iOS 13.0, *) {
                button.backgroundColor = .opaqueSeparator
                       } else {
                           button.backgroundColor = .lightGray
                       }
        }

        return updatedText.count <= 11
        
    }
    
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
