//
//  DjListTableViewController.swift
//  Player1n2a1r
//
//  Created by Egor Tkachenko on 06/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import UIKit
import Alamofire

class DjListTableViewController: UITableViewController {
    
    var djList: [DiscJockey] = [DiscJockey]()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateDjList()

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return djList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "djCell", for: indexPath) as! DjListTableViewCell
        
        cell.djName.text = djList[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPlayer", sender: self)
    }
    

    //MARK: - djList update methods
    func updateDjList() {
        let name = "m3s"
        getPlaylistStringForDj(name: name)
    }
    
    func getPlaylistStringForDj(name: String) {
        let url = "http://1n2a1r.com/audio/" + name + "/playlist"
        print(url)
        Alamofire.request(url, method: .get, parameters: nil)
            .response { response in
                if let playlistString = String(data: response.data!, encoding: .utf8) {
                    
                    print("Sucess! Got the playlist string: \(playlistString)")
                    self.updatePlaylistForDj(name: name, playlistString: playlistString)
                    
                } else {
                    print("Failed to get playlist!")
                }
        }
    }
    
    func updatePlaylistForDj(name: String, playlistString: String)  {
        let playlist = playlistString.components(separatedBy: "|")
        print("Sucess! Got the playlist: \(playlist)")
        djList.append(DiscJockey(name: name, playlist: playlist, isLiveBroadcasting: false))
        tableView.reloadData()
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlayer" {
            
            let destinationVC = segue.destination as! PlayerViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.currentDj = djList[indexPath.row]
            } else {
                print("Failed to set selectedCategory property!")
            }
            
        }
    }

}
