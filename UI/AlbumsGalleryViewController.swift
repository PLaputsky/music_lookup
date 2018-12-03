//
//  AlbumsGalleryViewController.swift
//  iTunesDemoApp
//
//  Created by Pavel Laputsky on 12/2/18.
//  Copyright © 2018 PavalLaputskyPersonal. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import Kingfisher

class AlbumsGalleryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.clipsToBounds = true
        clipsToBounds = true
    }
    
    override func prepareForReuse() {
        imageView.image = nil
    }
}

class AlbumsGalleryViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorButton: UIButton!
    
    @IBAction func onErrorButtonClickHandler() {
        navigationController?.popViewController(animated: true)
    }
    
    lazy var mapper: ModelsMapper = GenericDecodableMapper<LookUpModel>()
    var loadingResult: LookUpModel?
    
    var items: [LookUpItem]?
    var albums: [Int: [LookUpItem]]?
    
    class func instantiate(with lookUpItems: [LookUpItem]) -> AlbumsGalleryViewController {
        let viewController = StoryboardControllerProvider<AlbumsGalleryViewController>.controller(storyboardName: "Main")!
        
        viewController.items = lookUpItems
        viewController.albums = Dictionary(grouping: lookUpItems, by: { $0.collectionID! })
        
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Albums"
        setupCollectionView(collectionView)
        
        if items?.isEmpty ?? true {
            errorLabel.text = "There are no related albums.\nPlease go back and check this artist later"
            errorButton.setTitle("Go back", for: .normal)
            showError()
            return
        }
    }
    
    func showError() {
        errorLabel.isHidden = false
        errorButton.isHidden = false
        collectionView.isHidden = true
    }
    
    func setupCollectionView(_ collectionView: UICollectionView) {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.registerXib(for: AlbumsGalleryCollectionViewCell.self)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = .zero
        layout.sectionInset = .init(top: 15, left: 20, bottom: 15, right: 20)
        
        collectionView.collectionViewLayout = layout
    }
}

extension AlbumsGalleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let border = (collectionView.bounds.width / 2) - 30
        return CGSize(width: border, height: border + 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let albums = albums else { return }
        let targetKey = Array(albums.keys)[indexPath.item]
        guard let songs = albums[targetKey] else { return }
        
        let viewController = SongsViewController.instantiate(with: songs)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension AlbumsGalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.instantiateCell(at: indexPath, AlbumsGalleryCollectionViewCell.self)
       
        guard let albums = albums else { return cell }
        let targetKey = Array(albums.keys)[indexPath.item]
        guard let albumInfo = albums[targetKey]?.first else { return cell }
        
        
        if let imageUrlString = albumImageUlr(albumInfo.artworkUrl100), let imageUrl = URL(string:imageUrlString) {
            cell.imageView?.kf.setImage(with: imageUrl, options: [.transition(.fade(0.2))])
        }
        
        cell.artistName.text = albumInfo.artistName
        cell.albumName.text = albumInfo.collectionName

        return cell
    }
    
    func albumImageUlr(_ imageUrl: String?) -> String? {
        //https://is4-ssl.mzstatic.com/image/thumb/Music/v4/fd/a8/8e/fda88e68-e602-3409-37a1-91cb876a9cbb/source/500x500bb.jpg"
        let components = imageUrl?.components(separatedBy: "100x100")
        return components?.joined(separator: "300x300")
    }
}

extension UICollectionView {
    func instantiateCell<T: UICollectionViewCell>(at indexPath: IndexPath, _: T.Type) -> T {
        let nameSpaceClassName = NSStringFromClass(T.classForCoder())
        let cellIdentifier = nameSpaceClassName.components(separatedBy: ".").last!
        return dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! T
    }
    
    func registerXib(with nibDefaultName: String = "", for cellClass: AnyClass) {
        var nibName = nibDefaultName
        if nibName.isEmpty {
            let nameSpaceClassName = NSStringFromClass(cellClass)
            nibName = nameSpaceClassName.components(separatedBy: ".").last!
        }
        
        let nib = UINib(nibName: nibName, bundle: Bundle.main)
        register(nib, forCellWithReuseIdentifier: nibName)
    }
}
