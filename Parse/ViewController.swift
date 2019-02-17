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
    
    @IBAction func searchButton(_ sender: UIButton) {
        searchButton.setTitle("Close", for: .normal)
        scrape(url: makeURL())
    }
    
    func scrape(url: String) {
        Alamofire.request(url).responseString { response in
            if response.result.isSuccess {
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
    
}


