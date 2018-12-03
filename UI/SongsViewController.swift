//
//  SongsViewController.swift
//  iTunesDemoApp
//
//  Created by Pavel Laputsky on 12/2/18.
//  Copyright © 2018 PavalLaputskyPersonal. All rights reserved.
//

import UIKit
import SVProgressHUD
import Kingfisher
import MediaPlayer
import AVFoundation

enum SongsViewControllerSection: Int {
    case albumDetails = 0
    case songs
}

class AlbumDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var moreDetails: UILabel!
    
    override func awakeFromNib() {
        imageView?.image = nil
    }
}

class SongTableViewCell: UITableViewCell {
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
}

class SongsViewController: UIViewController {

    @IBOutlet weak var tableVIew: UITableView!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorButton: UIButton!
    
    @IBAction func onErrorButtonClickHandler() {
        navigationController?.popViewController(animated: true)
    }
    
    var player: AVAudioPlayer?
    
    lazy var httpService = HTTPClientQueue(maxConcurrentTasks: 5, operationsBuilder: HTTPOperationBuilderImp())
    lazy var mapper: ModelsMapper = GenericDecodableMapper<LookUpModel>()
    
    var loadingResult: LookUpModel?
    var songs: [LookUpItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableVIew.registerXib(for: AlbumDetailsTableViewCell.self)
        tableVIew.registerXib(for: SongTableViewCell.self)
        tableVIew.separatorStyle = .none
        
        title = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        player?.stop()
        player = nil
        SVProgressHUD.dismiss()
        
    }
    
    class func instantiate(with lookUpItems: [LookUpItem]) -> SongsViewController {
        let viewController = StoryboardControllerProvider<SongsViewController>.controller(storyboardName: "Main")!
        viewController.songs = lookUpItems.sorted(by: {$0.trackNumber ?? 0 < $1.trackNumber ?? 0})
        return viewController
    }
    
    func validateItems() {
        if loadingResult?.results.isEmpty ?? true {
            errorLabel.text = "There are no new relevant songs in this album.\nPlease go back and check the album later"
            errorButton.setTitle("Go back", for: .normal)
            showError()
            return
        }
    }
    
    func showError() {
        errorLabel.isHidden = false
        errorButton.isHidden = false
        tableVIew.isHidden = true
    }
}

extension SongsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch SongsViewControllerSection(rawValue: section) {
        case .albumDetails?: return 1
        case .songs?: return songs?.count ?? 0
        case .none: return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch SongsViewControllerSection(rawValue: indexPath.section) {
        case .albumDetails?: return albumDetailsCell(with: tableView, at: indexPath)
        case .songs?: return songCell(with: tableView, at: indexPath)
        case .none: return UITableViewCell()
        }
    }
    
    func albumDetailsCell(with tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.instantiateCell(at: indexPath, AlbumDetailsTableViewCell.self)!
        
        if let song = songs?.first {
            if let imageUrlString = song.artworkUrl100, let imageUrl = URL(string:imageUrlString) {
                cell.imageView?.kf.setImage(with: imageUrl, options: [.transition(.fade(0.2))],
                                            completionHandler: { (image, error, cacheType, url) in
                    cell.setNeedsLayout()
                })
            }
            
            cell.albumName.text = song.collectionName
            cell.artistName.text = song.artistName
            cell.moreDetails.text = song.primaryGenreName
        }
        
        return cell
    }
    
    func songCell(with tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.instantiateCell(at: indexPath, SongTableViewCell.self)!
        
        if let song = songs?[indexPath.row] {
            cell.numberLabel.text = "\(song.trackNumber ?? 0)"
            cell.songNameLabel.text = song.trackName ?? ""
        }
        
        return cell
    }
}

extension SongsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch SongsViewControllerSection(rawValue: indexPath.section) {
        case .albumDetails?: return
        case .songs?: handleSongTouch(in: tableView, at: indexPath)
        case .none: return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch SongsViewControllerSection(rawValue: indexPath.section) {
        case .albumDetails?: return 132
        case .songs?: return 60
        case .none: return 0
        }
    }
        
    func handleSongTouch(in tableView: UITableView, at index: IndexPath) {
        //guard let trackId = songs?[index.row].trackID else { return }
        //playTrack("\(trackId)")
        
        guard let preview = songs?[index.row].previewURL else { return }
        guard let url = URL(string: preview) else { return }
        downloadSong(withUrl: url)
    }
    
    func playTrack(_ trackId: String) {
        let applicationMusicPlayer = MPMusicPlayerController.applicationMusicPlayer
        applicationMusicPlayer.setQueue(with: [trackId])
        applicationMusicPlayer.play()
        
    }
    
    func downloadSong(withUrl url: URL) {
        SVProgressHUD.show()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let task = URLSession.shared.downloadTask(with: url) { [weak self] (localUrl, response, error) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            guard let url = localUrl else { return }
            
            if error != nil || localUrl == nil {
                self?.handleError()
                return
            }
            
            do {
                self?.player = try AVAudioPlayer(contentsOf: url)
                self?.player?.play()
            } catch {
                self?.handleError()
            }
            
        }
        task.resume()
    }
    
    func handleError() {
        DispatchQueue.main.async { [weak self] in
            let alertConroller = UIAlertController(title: "Loading error",
                                                   message: "Song loading failed.\nPlease check your Internent connection,\nand try again.",
                                                   preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertConroller.addAction(okAction)
            self?.show(alertConroller, sender: nil)
        }
    }
}


