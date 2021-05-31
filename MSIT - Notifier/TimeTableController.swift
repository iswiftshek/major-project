//
//  TimeTableController.swift
//  MSIT - Notifier
//
//  Created by Abhishek Sansanwal on 26/11/20.
//  Copyright © 2020 Verved. All rights reserved.
//

import UIKit
import WebKit
import SwiftSoup

class TimeTableController: UIViewController, UITabBarDelegate, WKNavigationDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        timeTableLink = currentShiftLinks[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currentShift[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentShift.count
    }
    
    
    @IBOutlet weak var shiftDecider: UISegmentedControl!
    @IBOutlet weak var branchPicker: UIPickerView!
    @IBAction func buttonPressed(_ sender: Any) {
        view.addSubview(self.blurView)
        
        let linkURLFinal = URL(string: timeTableLink)!
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
    
    var url = URL(string: "http://www.msit.in/timetable")!
       
       var activityIndicator: UIActivityIndicatorView!
       let webView = WKWebView()
       let closeButton = UIButton()
       let blur = UIBlurEffect(style: UIBlurEffect.Style.light)
       var blurView = UIVisualEffectView()
       
       var titleOfItem: [String] = []
       var link: [String] = []
    
    var morningBranches: [String] = []
    var eveningBranches: [String] = []
    
    var currentShift: [String] = []
    var currentShiftLinks: [String] = []
    
    var morningLinks: [String] = []
    var eveningLinks: [String] = []
    var timeTableLink = ""

       override func viewDidLoad()
       {
           super.viewDidLoad()
           self.run()
           
           blurView = UIVisualEffectView(effect: self.blur)
           blurView.frame = self.view.bounds
           webView.navigationDelegate = self
        branchPicker.delegate = self
        branchPicker.dataSource = self
           
           closeButton.setImage(UIImage(named: "close"), for: .normal)
           closeButton.frame = CGRect(x: UIScreen.main.bounds.width/2 - 20, y: 100, width: 40, height: 40)
           closeButton.addTarget(self, action: #selector(pressed), for: .touchUpInside)
        
        shiftDecider.addTarget(self, action: #selector(segmentedControlValueChanged), for:.valueChanged)
           
       }
    
    @objc func segmentedControlValueChanged(segment: UISegmentedControl) {
        if segment.selectedSegmentIndex == 0 {
            currentShift = morningBranches
            currentShiftLinks = morningLinks
            branchPicker.reloadAllComponents()
        }
        else {
            currentShift = eveningBranches
            currentShiftLinks = eveningLinks
            branchPicker.reloadAllComponents()
        }
    }
       
       let defaultSession = URLSession(configuration: .default)
       var dataTask: URLSessionDataTask?
       
       @objc func pressed(sender: UIButton!) {
           self.webView.removeFromSuperview()
           self.closeButton.removeFromSuperview()
           self.activityIndicator.removeFromSuperview()
           self.blurView.removeFromSuperview()
       }
       
       func run()
       {
           titleOfItem.removeAll()
           link.removeAll()
           
           let html = try! String(contentsOf: url, encoding: .utf8)

           do {
               let doc: Document = try SwiftSoup.parseBodyFragment(html)
            let Notice: [Element] = try doc.getElementsByClass("tab-pane").array()
               
            let morning = try Notice[0].select("p").array()
            let evening = try Notice[1].select("p").array()
            
            for i in 0..<morning.count {
                morningLinks.append("http://www.msit.in\(try morning[i].select("a").attr("href"))")
                morningBranches.append(try morning[i].select("p").text().replacingOccurrences(of: " - Click Here", with: ""))
            }
            
            for i in 0..<evening.count {
                eveningLinks.append("http://www.msit.in\(try evening[i].select("a").attr("href"))")
                eveningBranches.append(try evening[i].select("p").text().replacingOccurrences(of: " - Click Here", with: ""))
            }
            currentShift = morningBranches
            currentShiftLinks = morningLinks
            branchPicker.reloadAllComponents()
           }
               
            catch Exception.Error( _, let message) {
               print("Message: \(message)")
           } catch {
               print("error")
           }
       }
       
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

           view.addSubview(self.blurView)
           
           let linkURLFinal = URL(string: link[indexPath.row])!
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
       
       func showActivityIndicator(show: Bool) {
           if show {
               activityIndicator.startAnimating()
           } else {
               activityIndicator.stopAnimating()
           }
       }

       func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
           showActivityIndicator(show: false)
       }

       func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
           showActivityIndicator(show: true)
       }

       func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
           showActivityIndicator(show: false)
       }


}
