//
//  NewsController.swift
//  MSIT - Notifier
//
//  Created by Abhishek Sansanwal on 26/11/20.
//  Copyright © 2020 Verved. All rights reserved.
//

import UIKit
import WebKit
import SwiftSoup
 
class NewsController: UIViewController, UITabBarDelegate, UITableViewDelegate, UITableViewDataSource, WKNavigationDelegate {
    

    @IBOutlet weak var tableView: UITableView!
    
    let cellReuseIdentifier = "cell"
    var url = URL(string: "http://www.msit.in/latest_news")!
    
    var activityIndicator: UIActivityIndicatorView!
    let webView = WKWebView()
    let closeButton = UIButton()
    let blur = UIBlurEffect(style: UIBlurEffect.Style.light)
    var blurView = UIVisualEffectView()
    
    var titleOfItem: [String] = []
    var link: [String] = []

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.run()
        
        blurView = UIVisualEffectView(effect: self.blur)
        blurView.frame = self.view.bounds
        webView.navigationDelegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = UIColor.gray
        tableView.tableFooterView = UIView()
        
        closeButton.setImage(UIImage(named: "close"), for: .normal)
        closeButton.frame = CGRect(x: UIScreen.main.bounds.width/2 - 20, y: 100, width: 40, height: 40)
        closeButton.addTarget(self, action: #selector(pressed), for: .touchUpInside)
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
    }
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    @objc func pressed(sender: UIButton!) {
        self.webView.removeFromSuperview()
        self.closeButton.removeFromSuperview()
        self.activityIndicator.removeFromSuperview()
        self.blurView.removeFromSuperview()
        self.tableView.reloadData()
    }
    
    func run()
    {
        titleOfItem.removeAll()
        link.removeAll()
        
        let html = try! String(contentsOf: url, encoding: .utf8)

        do {
            let doc: Document = try SwiftSoup.parseBodyFragment(html)
            let Notice: [Element] = try doc.getElementsByClass("tab-content").select("li").array()
            
            for i in 0..<Notice.count {
                titleOfItem.append(try Notice[i].select("a").text())
                let linkExtension = try Notice[i].select("a").attr("href")
                link.append("http://www.msit.in\(linkExtension)")
            }
        }
            
         catch Exception.Error( _, let message) {
            print("Message: \(message)")
        } catch {
            print("error")
        }
        self.tableView.reloadData()
    }
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.link.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)! as UITableViewCell
        cell.textLabel?.text = self.titleOfItem[indexPath.row]
        return cell
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

