//
//  ViewController.swift
//  iTunesDemoApp
//
//  Created by Pavel Laputsky on 12/2/18.
//  Copyright © 2018 PavalLaputskyPersonal. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import Kingfisher
import Reachability

class ViewController: UIViewController {

    @IBOutlet weak var tableVIew: UITableView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorButton: UIButton!
    
    @IBAction func onErrorButtonClickHandler() {
        updateData()
    }
    
    lazy var mapper: ModelsMapper = GenericDecodableMapper<LookUpModel>()
    
    var loadingResult: LookUpModel?
    var artists: [LookUpItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Artists"
        tableVIew.isHidden = true
        
        switch Reachability()!.connection {
        case .cellular, .wifi: updateData()
        case .none: handleError()
        }
    }
    
    func updateData() {
        SVProgressHUD.show()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let url = URL(string: "https://itunes.apple.com/lookup?amgArtistId=468749,5723,2347,13987,234&entity=song&limit=500")!
//        let url = URL(string: "https://itunes.apple.com/lookup?amgArtistId=461231238749&entity=songas&limit=500")!
        let task = URLSession.shared.downloadTask(with: url) { [weak self] (localUrl, response, error) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            if let error = error {
                self?.handleError(error)
                return
            }
            
            guard let localURL = localUrl else { return }
            guard let data = try? Data(contentsOf: localURL, options: .mappedIfSafe) else { return }
            self?.loadingResult = self?.mapper.performMapping(data: data)
            
            DispatchQueue.main.async {
                self?.loadingDidComplete()
            }
        }
        task.resume()
    }
    
    func updateArtistsList() {
        artists =  loadingResult?.results
            .filter{ $0.wrapperType?.lowercased() == "artist" }
            .sorted{ ($0.artistName ?? "") < ($1.artistName ?? "")}
        
        if artists?.isEmpty ?? true {
            errorLabel.text = "There are no related artists.\nPlease try to refresh data"
            errorButton.setTitle("Refresh data", for: .normal)
            showError()
            return
        }

        tableVIew.isHidden = false
    }
    
    func loadingDidComplete() {
        updateArtistsList()
        self.tableVIew.reloadData()
    }

    func handleError(_ error: Error? = nil) {
        errorLabel.text = "Something was going wrong.\nPlease check Internet connection\nand try to refresh data"
        errorButton.setTitle("Refresh data", for: .normal)
        showError()
    }
    
    func showError() {
        errorLabel.isHidden = false
        errorButton.isHidden = false
        tableVIew.isHidden = true
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artists?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.accessoryType = .disclosureIndicator
    
        let artist = artists?[indexPath.row]
        
        cell.textLabel?.text = artist?.artistName
        
        if let imageUrlString = artist?.artworkUrl100, let imageUrl = URL(string:imageUrlString) {
            cell.imageView?.kf.setImage(with: imageUrl, options: [.transition(.fade(0.2))])
        }
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard let selectedArtist = artists?[indexPath.row] else { return }
        guard let songs = loadingResult?.results.filter({ $0.wrapperType == "track" && $0.artistID == selectedArtist.artistID}) else { return }
        
        
        let viewController = AlbumsGalleryViewController.instantiate(with: songs)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
