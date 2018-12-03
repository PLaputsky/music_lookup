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
import Reachability

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

protocol SongTableViewCellDelegate: class {
    func didClickOnDownloadButton(with index: IndexPath)
}

class SongTableViewCell: UITableViewCell {
    weak var delegate: SongTableViewCellDelegate?
    var indexPath: IndexPath?
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var actionImage: UIImageView!
    
    @IBAction func didSelectDownloadButton() {
        guard let indexPath = indexPath else { return }
        delegate?.didClickOnDownloadButton(with: indexPath)
    }
}

class SongsViewController: UIViewController {

    @IBOutlet weak var tableVIew: UITableView!
    
    @IBOutlet weak var touchPreventView: UIView!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorButton: UIButton!
    
    @IBAction func onErrorButtonClickHandler() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var currentSongImageView: UIImageView!
    @IBOutlet weak var currentSongLabel: UILabel!
    @IBOutlet weak var playStopButton: UIButton!
    
    var currentSongIndex: Int?
    var player: AVAudioPlayer?
    
    lazy var httpService = HTTPClientQueue(maxConcurrentTasks: 5, operationsBuilder: HTTPOperationBuilderImp())
    lazy var mapper: ModelsMapper = GenericDecodableMapper<LookUpModel>()
    
    var songs: [LookUpItem]?
    var presavedSongs: [LookUpItem]?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        touchPreventView.isHidden = true
        
        tableVIew.registerXib(for: AlbumDetailsTableViewCell.self)
        tableVIew.registerXib(for: SongTableViewCell.self)
        tableVIew.separatorStyle = .none
        
        title = ""
        
        fetchPresavedSongs()
        validateItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
        if songs?.isEmpty ?? true {
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
    
    func fetchPresavedSongs() {
        guard let savedSongsData = UserDefaults.standard.object(forKey: "songs") as? Data else { return }
        guard let savedSongs = try? JSONDecoder().decode(Array<LookUpItem>.self, from: savedSongsData) else { return }
        
        presavedSongs = savedSongs
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
        cell.delegate = self
        cell.indexPath = indexPath
        
        if let song = songs?[indexPath.row] {
            
            if presavedSongs?.contains(where: { $0.trackID == song.trackID }) == true {
                cell.actionImage.image = UIImage(named: "Loaded")
                cell.actionButton.isHidden = true
            }
            
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
        guard let song = songs?[index.row],
            let preview = song.previewURL,
            let url = URL(string: preview) else {
                handlePrrviewError()
                return
        }
        
        currentSongIndex = index.row
        
        downloadSong(withUrl: url) { [weak self] data, url in
            DispatchQueue.main.async {
                self?.playSong(with: data)
            }
        }
    }
    
    func downloadSong(withUrl url: URL, completionHandler: @escaping (Data, URL?) -> Void) {
        if Reachability()!.connection == .none {
            handleError()
            return
        }
        
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
            completionHandler(cachedResponse.data, url)
            return
        }
        
        SVProgressHUD.show()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        touchPreventView.isHidden = false
        
        let task = URLSession.shared.downloadTask(with: request) { [weak self] (localUrl, response, error) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self?.touchPreventView.isHidden = true
            }
            
            guard let url = localUrl, error == nil,
                let data = try? Data(contentsOf: url) else {
                self?.handleError()
                return
            }
            
            if let response = response, URLCache.shared.cachedResponse(for: request) == nil {
                let cachedResponse = CachedURLResponse(response: response, data: data)
                URLCache.shared.storeCachedResponse(cachedResponse, for: request)
            }
            
            completionHandler(data, response?.url)
        }
        task.resume()
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
                                                   message: "Preview is not available fot this song.\nPlease select another song to listen preview",
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

extension SongsViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        togglePlayerButton()
    }
}

extension SongsViewController: SongTableViewCellDelegate {
    func didClickOnDownloadButton(with index: IndexPath) {
        saveSong(at: index)
    }
    
    func saveSong(at index: IndexPath) {
        guard let song = songs?[index.row],
            let preivewUrlString = song.previewURL,
            let preivewUrl = URL(string: preivewUrlString) else { return }
        
        downloadSong(withUrl: preivewUrl) { [weak self] data, url in
            do {
                let fileName = url?.lastPathComponent
                let dirUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let fileURL = dirUrl.appendingPathComponent(fileName!)
                try data.write(to: fileURL)
                
            } catch {
                self?.handleError()
            }
            
            self?.saveSongInfo(with: url)
        }
    }
    
    func saveSongInfo(with url: URL?) {
        guard let url = url, let songIndex = songs?.firstIndex(where: {$0.previewURL?.contains(url.lastPathComponent) ?? false}), let song = songs?[songIndex] else {
            handleError()
            return
        }
        
        var presavedSongs = self.presavedSongs ?? []
        presavedSongs.append(song)
        
        guard let encoded = try? JSONEncoder().encode(presavedSongs) else {
            handleError()
            return
        }
        
        UserDefaults.standard.set(encoded, forKey: "songs")
        
        DispatchQueue.main.async { [ weak self] in
            let indexPath = IndexPath.init(row: songIndex, section: SongsViewControllerSection.songs.rawValue)
            self?.presavedSongs = presavedSongs
            self?.tableVIew.reloadRows(at: [indexPath], with: .fade)
        }
    }
}
