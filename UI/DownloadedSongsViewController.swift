//
//  DownloadedSongsViewController.swift
//  iTunesDemoApp
//
//  Created by Pavel Laputsky on 12/3/18.
//  Copyright © 2018 PavalLaputskyPersonal. All rights reserved.
//

import UIKit
import Kingfisher
import MediaPlayer
import AVFoundation

class DownloadedSongTableViewCell: UITableViewCell {
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
}

class DownloadedSongsViewController: UIViewController {
    
    @IBOutlet weak var tableVIew: UITableView!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorButton: UIButton!
    
    @IBAction func onErrorButtonClickHandler() {
        tabBarController?.selectedIndex = 0
    }
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var currentSongImageView: UIImageView!
    @IBOutlet weak var currentSongLabel: UILabel!
    @IBOutlet weak var playStopButton: UIButton!
    
    @IBAction func playStopAction() {
        
        if currentSongIndex == nil, songs?.isEmpty == false {
            handleSongTouch(in: tableVIew, at: .init(row: 0, section: 0))
            return
        }
        
        if player?.isPlaying == true {
            player?.pause()
        } else {
            player?.play()
        }
        
        togglePlayerButton()
    }
    
    var currentSongIndex: Int?
    var player: AVAudioPlayer?
    
    lazy var mapper: ModelsMapper = GenericDecodableMapper<LookUpModel>()
    
    var songs: [LookUpItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableVIew.separatorStyle = .none
        tableVIew.registerXib(for: DownloadedSongTableViewCell.self)
        
        title = "Saved songs"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchSavedSongs()
        validateItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.stop()
        player = nil
    }
    
    func registerObservation() {
        UserDefaults.standard.addObserver(self, forKeyPath: "songs", options: .new, context: nil)
    }
    
    func fetchSavedSongs() {
        guard let savedSongsData = UserDefaults.standard.object(forKey: "songs") as? Data else { return }
        guard let savedSongs = try? JSONDecoder().decode(Array<LookUpItem>.self, from: savedSongsData) else { return }
        
        songs = savedSongs
        tableVIew.reloadData()
    }
    
    class func instantiate(with lookUpItems: [LookUpItem]) -> DownloadedSongsViewController {
        let viewController = StoryboardControllerProvider<DownloadedSongsViewController>.controller(storyboardName: "Main")!
        viewController.songs = lookUpItems.sorted(by: {$0.trackNumber ?? 0 < $1.trackNumber ?? 0})
        return viewController
    }
    
    func validateItems() {
        if songs?.isEmpty ?? true {
            errorLabel.text = "You have no any saved song yet.\n\nLet's go to the Favorive tab\nand save some cool tracks"
            errorButton.setTitle("Go to Favorite tab", for: .normal)
            showError()
        } else {
            showContent()
        }
    }
    
    func showError() {
        errorLabel.isHidden = false
        errorButton.isHidden = false
        tableVIew.isHidden = true
        playerView.isHidden = true
    }
    
    func showContent() {
        errorLabel.isHidden = true
        errorButton.isHidden = true
        tableVIew.isHidden = false
        playerView.isHidden = false
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "song" {
            tableVIew.reloadData()
        }
    }
}

extension DownloadedSongsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return songCell(with: tableView, at: indexPath)
    }
    
    func songCell(with tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.instantiateCell(at: indexPath, DownloadedSongTableViewCell.self)!
        
        if let song = songs?[indexPath.row] {
            if let imageUrlString = song.artworkUrl100, let imageUrl = URL(string:imageUrlString) {
                cell.albumImageView?.kf.setImage(with: imageUrl, options: [.transition(.fade(0.2))],
                                                 completionHandler: { (image, error, cacheType, url) in
                                                    cell.setNeedsLayout()
                })
            }
            
            cell.songNameLabel.text = song.trackName
            cell.albumNameLabel.text = song.collectionName
        }
        
        return cell
    }
}

extension DownloadedSongsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        handleSongTouch(in: tableView, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func handleSongTouch(in tableView: UITableView, at index: IndexPath) {
        guard let song = songs?[index.row],
            let preview = song.previewURL,
            let url = URL(string: preview) else {
                handlePrrviewError()
                return
        }
        
        currentSongIndex = index.row
        
        downloadSong(withUrl: url)
    }
    
    func downloadSong(withUrl url: URL) {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
            playSong(with: cachedResponse.data)
            return
        }
        
        do {
            let fileName = url.lastPathComponent
            let dirUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = dirUrl.appendingPathComponent(fileName)
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                handleDataError()
                return
            }
            let data = try Data(contentsOf: fileURL)
            playSong(with: data)
        } catch {
            self.handleDataError()
        }
    }
    
    func playSong(from url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.play()
            updatePlayerWithCurrentSong()
            togglePlayerButton()
        } catch {
            handleError()
        }
    }
    
    func playSong(with data: Data) {
        do {
            player = try AVAudioPlayer(data: data)
            player?.delegate = self
            player?.play()
            updatePlayerWithCurrentSong()
            togglePlayerButton()
        } catch {
            handleError()
        }
    }
    
    func handleError() {
        DispatchQueue.main.async { [weak self] in
            let alertConroller = UIAlertController(title: "Loading error",
                                                   message: "Song loading failed.\nPlease check your Internent connection,\nand try again.",
                                                   preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertConroller.addAction(okAction)
            self?.present(alertConroller, animated: true, completion: nil)
        }
    }
    
    func handlePrrviewError() {
        DispatchQueue.main.async { [weak self] in
            let alertConroller = UIAlertController(title: "Priview error",
                                                   message: "Preview is not available fot this song.\nPlease select another song to listen",
                                                   preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertConroller.addAction(okAction)
            self?.present(alertConroller, animated: true, completion: nil)
        }
    }
    
    func handleDataError() {
        DispatchQueue.main.async { [weak self] in
            let alertConroller = UIAlertController(title: "Data error",
                                                   message: "Seems like song data in not available,\nor was currapted.\n\nPlease select another song to listen",
                                                   preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertConroller.addAction(okAction)
            self?.present(alertConroller, animated: true, completion: nil)
        }
    }
    
    func updatePlayerWithCurrentSong() {
        guard let index = currentSongIndex else { return }
        guard let currentSong = songs?[index] else { return }
        currentSongLabel.text = currentSong.trackName
        if let imageUrlString = currentSong.artworkUrl60, let imageUrl = URL(string:imageUrlString) {
            currentSongImageView.kf.setImage(with: imageUrl, options: [.transition(.fade(0.2))],
                                             completionHandler: nil)
        }
    }
    
    func togglePlayerButton() {
        if player?.isPlaying == true {
            playStopButton.setImage(UIImage(named: "Pause"), for: .normal)
        } else {
            playStopButton.setImage(UIImage(named: "Play"), for: .normal)
        }
    }
}

extension DownloadedSongsViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        togglePlayerButton()
    }
}
