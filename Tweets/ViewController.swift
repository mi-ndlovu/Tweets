//
//  ViewController.swift
//  Tweets
//
//  Created by Mbongeni NDLOVU on 2018/10/05.
//  Copyright © 2018 mndlovu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var search: UITextField!
    var twitterDelegate :APITwitterDelegate!
    var apiConroller: APIController!
    var tweets: [Tweet] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.twitterDelegate = self
        search.delegate = self
        getToken()
    }
    
    func getToken() {
        let CONSUMER_KEY = "3NbErRWk7FGvuGaqul0g3dqYU"
        let CONSUMER_SECRET = "3vn4w3mFjQK6mWCknANseyPva12usYrbwIh8JwZrkwM3ZstsPi"
        let BEARER = ((CONSUMER_KEY + ":" + CONSUMER_SECRET).data(using: String.Encoding.utf8))!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        let url = NSURL(string: "https://api.twitter.com/oauth2/token")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        request.setValue("Basic \(BEARER)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: String.Encoding.utf8)
        URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
            if let err = error {
                print(err)
            }
            else if let d = data {
                do {
                    if let resp: NSDictionary = try JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                        if let token = resp["access_token"] as? String{
                           self.apiConroller = APIController(delegate: self.twitterDelegate, token: token )
                        }
                    }
                }
                catch (let err) {
                    print(err)
                }
            }
        }.resume()
    }

}

// MARK : UITableViewDataSource implimentation

extension ViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        let dateString = tweets[indexPath.row].date
        let len = dateString.count
        cell.myDate.text = (dateString as NSString).substring(to: len - 14)
        cell.myText.text = tweets[indexPath.row].text
        cell.myName.text = tweets[indexPath.row].name
        return cell
    }
    
    
}

extension ViewController : UITableViewDelegate {
    // design a cell
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.white
        } else {
            cell.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        }
    }
}

// MARK : APITwitterDelegate implimentation

extension ViewController: APITwitterDelegate {
    func processRecievedTweets(tweets: [Tweet]) {
        self.tweets = tweets
        self.tableView.reloadData()
    }
    
    func handleError(error: NSError) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        self.present(alert,animated: true, completion: nil)
    }
}

// MARK : UITextFieldDelegate implimentation

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.tweets = []
        self.apiConroller.getTweets(textField.text!)
        return true
    }
}


