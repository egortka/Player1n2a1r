//
//  PlayerViewController.swift
//  Player1n2a1r
//
//  Created by Egor Tkachenko on 06/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import UIKit
import MediaPlayer


class PlayerViewController: UIViewController, VLCMediaPlayerDelegate, UIApplicationDelegate {

    var currentDj: DiscJockey?
    var currentSongIndex = 0
    var isPlaying = false
    var isNewSecond = false
    
    
    var time: VLCTime = VLCTime()
    var timer: Timer = Timer()
    var songLength: VLCTime?
    
    var mediaPlayer = VLCMediaPlayer()
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var progressBar: UISlider!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var playerToolbar: UIToolbar!
    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var remainTime: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //progressBar.setThumbImage(UIImage(), for: .normal)
        progressBar.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        mediaPlayer.delegate = self
        setOnPlay()
        setupRemoteTransportControls()
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            self.isNewSecond = true
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mediaPlayer.stop()
    }

    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        updatePlayer()
    }


    //MARK: - toolbar buttons touch methods
    
    @IBAction func playButtonTouched(_ sender: Any) {
        if isPlaying {
            setOnPause()
        } else {
            setOnPlay()
        }
    }
    
    @IBAction func backButtonTouched(_ sender: Any) {
        setPrevious()
    }

    @IBAction func nextButtonTouched(_ sender: Any) {
        setNext()
    }
    
    //MARK: - player logic
    
    func setNext() {
        if let currentPlaylist = currentDj?.playlist {
            mediaPlayer.stop()
            if currentSongIndex == currentPlaylist.count - 1 && currentPlaylist.count > 0{
                currentSongIndex = 0
            } else if currentSongIndex < currentPlaylist.count - 1 {
                currentSongIndex += 1
            }
            if isPlaying{
                playSong()
            } else {
                setSong()
            }
        }
        print(currentSongIndex)
    }
    
    func setPrevious() {
        if let currentPlaylist = currentDj?.playlist {
            mediaPlayer.stop()
            if currentSongIndex == 0 && currentPlaylist.count > 0{
                currentSongIndex = currentDj!.playlist.count - 1
            } else if currentSongIndex > 0 {
                currentSongIndex -= 1
            }
            if isPlaying{
                playSong()
            } else {
                setSong()
            }
        }
        print(currentSongIndex)
    }
    
    func setOnPause() {
        var items = playerToolbar.items
        items![3] = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(playButtonTouched(_:)))
        isPlaying = false
        mediaPlayer.pause()
        playerToolbar.setItems(items, animated: true)
    }
    
    func setOnPlay() {
        var items = playerToolbar.items
        items![3] = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(playButtonTouched(_:)))
        isPlaying = true
        if mediaPlayer.position > 0 {
            mediaPlayer.play()
        } else {
            playSong()
        }
        playerToolbar.setItems(items, animated: true)
    }
    
    func getSongName() {
        if var songName = currentDj?.playlist[currentSongIndex] {
            if let range = songName.range(of: ".mp3") {
                songName.removeSubrange(range)
                songLabel.text = songName
            }
        }
    }
    
    func setSong() {
        mediaPlayer.stop()
        getSongName()
        wipeProgressBar()
        updateProgressBar()
        let url = "http://1n2a1r.com/audio/" + currentDj!.name + "/" + currentDj!.playlist[currentSongIndex]
        //let url = "http://stream.radioreklama.bg:80/nrj_low.ogg"
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: " ").inverted)
        mediaPlayer.media = VLCMedia(url: URL(string: encodedUrl!)!)
        
    }
    
    func playSong() {
        setSong()
        mediaPlayer.play()
    }
    
    @objc func updatePlayer() {
        setupNowPlaying()
        updateProgressBar()
        checkForSongFinish()
    }
    
    //MARK: - Background controls
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            print(self.mediaPlayer.rate)
            if !self.isPlaying {
                self.setOnPlay()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            print(self.mediaPlayer.rate)
            if self.isPlaying {
                self.setOnPause()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            self.setPrevious()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            self.setNext()
            return .success
        }
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget(self, action:#selector(changePlaybackPositionCommand(_:)))
    
    }
    @objc func changePlaybackPositionCommand(_ event:MPChangePlaybackPositionCommandEvent) -> MPRemoteCommandHandlerStatus{
        let currentPosition = Float(event.positionTime)
        let currentLength = Float(mediaPlayer.media.length.intValue) / 1000.0
        mediaPlayer.position = currentPosition / currentLength
        return MPRemoteCommandHandlerStatus.success;
    }
    
    
    func setupNowPlaying() {
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = songLabel.text
        
        if let image = UIImage(named: "logo_black") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
                MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
            }
        }

        
    
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Double(mediaPlayer.time.intValue) / 1000.0
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = Double(mediaPlayer.media.length.intValue) / 1000.0
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    //MARK: - progress bar methods
    
    func updateProgressBar() {
        progressBar.value = mediaPlayer.position
        
        if let time = mediaPlayer.time,
            let media = mediaPlayer.media {
            
            let playTimeValue = time.intValue / 1000
            let remainTimeValue = media.length.intValue / 1000 - playTimeValue
            
            self.playTime.text = playTimeValue > 0 ? createTimeString(seconds: playTimeValue) : "00:00"
            self.remainTime.text = createTimeString(seconds: remainTimeValue)
        }
        
    }
    
    func wipeProgressBar() {
        progressBar.value = 0
        self.playTime.text = "00:00"
        if let media = mediaPlayer.media {
            self.remainTime.text = createTimeString(seconds: media.length.intValue / 1000)
        } else {
            self.remainTime.text = "00:00"
        }
    }
    
    @IBAction func didDrugProgressBar(_ sender: Any) {
        checkForSongFinish()
    }

    
    @IBAction func drugProgressBar(_ sender: Any) {
            mediaPlayer.position = progressBar.value
    }
    
    //MARK: - helpers methods
    
    func checkForSongFinish() {
        if progressBar.value == 1.0 {
            setNext()
        }
    }
    
//    func scheduleTimer() {
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
//            self.updatePlayer()
//        })
//    }
    func createTimeString(seconds: Int32) -> String {
        if let time = VLCTime.init(int: seconds * 1000){
            return time.stringValue
        } else {
            return "00:00"
        }
    }
}
