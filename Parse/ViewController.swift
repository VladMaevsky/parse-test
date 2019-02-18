//
//  ViewController.swift
//  Parse
//
//  Created by Vlad Maevsky on 2/11/19.
//  Copyright © 2019 Vlad Maevsky. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    
    var resultNames = [String]()
    var resultLinks = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = resultNames[indexPath.row]
        cell.detailTextLabel?.text = resultLinks[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = URL(string: resultLinks[indexPath.row])
        if let url = url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func searchButton(_ sender: UIButton) {
        if self.searchButton.title(for: .normal) == "Google Search" {
            searchButton.setTitle("Close", for: .normal)
            scrape(url: makeURL())
        } else {
            Alamofire.SessionManager.default.session.getAllTasks { tasks in
                tasks.forEach{ $0.cancel() }
            }
            searchButton.setTitle("Google Search", for: .normal)
        }
        
    }
    
    func scrape(url: String) {
        Alamofire.request(url).responseString { response in
            if response.result.isSuccess {
                print(response.result.isSuccess)
                self.resultNames.removeAll()
                self.resultLinks.removeAll()
                self.tableView.reloadData()
            }
            if let html = response.result.value {
                self.parseHTML(html: html)
            }
        }
    }
    
    func parseHTML(html: String) {
        if let doc = try? Kanna.HTML(html: html, encoding: .utf8) {
            for link in doc.css("h3") {
                if link.text != "Images for " + textField.text! {
                    resultNames.append(link.text!)
                }
            }
            for link in doc.css("cite") {
                resultLinks.append(link.text!)
            }
        }
        tableView.reloadData()
        searchButton.setTitle("Google Search", for: .normal)
    }
    
    func makeURL() -> String {
        let defaultUrl = "https://www.google.com/search?q="
        var str = ""
        for symbol in textField.text! {
            if symbol == " " {
                str += "+"
            } else {
                str += String(symbol)
            }
        }
        return defaultUrl + str
    }
    
    func strToURL (str: String) {
        let regex = try? NSRegularExpression(pattern: "^http", options: .caseInsensitive)
        if ((regex?.matches(in: str, options: .anchored, range: NSRange(location: 0, length: str.count))) != nil) {
            print(regex)
        }
        
    }
    
}


