//
//  PlayerViewController.swift
//  Player1n2a1r
//
//  Created by Egor Tkachenko on 06/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {

    var currentDj: DiscJockey?
    var currentSongIndex = 0
    var isPlaying = false
    
    @IBOutlet weak var progressBar: UIView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var playerToolbar: UIToolbar!
    @IBOutlet weak var playButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playSong(with: 0)
    
    }

    //MARK: - toolbar buttons touch methods
    
    @IBAction func backButtonTouched(_ sender: Any) {
        if let currentPlaylist = currentDj?.playlist {
            if currentSongIndex == 0 && currentPlaylist.count > 0{
                currentSongIndex = currentDj!.playlist.count - 1
            } else if currentSongIndex > 0 {
                currentSongIndex -= 1
            }
        }
        print(currentSongIndex)
        
    }
    @IBAction func playButtonTouched(_ sender: Any) {
        if isPlaying {
            setOnPause()
        } else {
            setOnPlay()
        }
        
    }
    @IBAction func nextButtonTouched(_ sender: Any) {
        if let currentPlaylist = currentDj?.playlist {
            if currentSongIndex == currentPlaylist.count - 1 && currentPlaylist.count > 0{
                currentSongIndex = 0
            } else if currentSongIndex < currentPlaylist.count - 1 {
                currentSongIndex += 1
            }
        }
        print(currentSongIndex)
    }
    
    //MARK: - player methods
    
    func playSong(with index: Int) {
        if let nextSong = currentDj?.playlist[index] {
            songLabel.text = nextSong
        }
    }
    
    func setOnPause() {
        var items = playerToolbar.items
        items![3] = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(playButtonTouched(_:)))
        isPlaying = false
        playerToolbar.setItems(items, animated: true)
    }
    
    func setOnPlay() {
        var items = playerToolbar.items
        items![3] = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(playButtonTouched(_:)))
        isPlaying = true
        playerToolbar.setItems(items, animated: true)
    }
    
}
