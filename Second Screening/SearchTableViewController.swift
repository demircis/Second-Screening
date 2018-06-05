//
//  FirstViewController.swift
//  Second Screening
//
//  Created by Sinan Demirci on 19.05.18.
//  Copyright © 2018 Sinan Demirci. All rights reserved.
//

import UIKit
import Kingfisher

class SearchTableViewController: UITableViewController, UISearchBarDelegate {
        
    @IBOutlet weak var searchBar: UISearchBar!
    
    var mediaItems = [MediaItem]()
    
    var requestManager: RequestManager?
    var fileManager: FileManager = FileManager()
    
    var srtDelegate: SrtDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestManager = RequestManager(delegate: self)
        searchBar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        mediaItems.removeAll()
        searchBar.endEditing(true)
        requestManager?.sendSubtitlesRequest(searchBar: searchBar)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediaItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MediaItemViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SearchResultsTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MediaItemViewCell.")
        }
        if (mediaItems.count == 0) {
            print("items count: " + String(mediaItems.count))
        }
        let item = mediaItems[indexPath.row]
        // Configure the cell...
        cell.coverImage.image = item.coverImage
        cell.mediaTitle.text = item.mediaTitle.replacingOccurrences(of: "\"", with: "")
        cell.episodeTitle.text = item.seasonAndEpisode + " - " + item.episodeTitle
        cell.subtitleTitle.text = item.subtitleTitle
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SubtitlesViewController {
            self.srtDelegate = destination
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = mediaItems[indexPath.row]
        item.downloadSubtitlesZip() { url, enc in
            print("srt done")
            if !self.fileManager.fileExists(atPath: url.path) {
                self.showNotFoundAlert()
            } else {
                self.srtDelegate?.passSrtInfo(fileURL: url, encoding: enc, runtime: item.runtime)
            }
        }
    }

    func showNotFoundAlert() {
        let alertController = UIAlertController(title: "Subtitles", message: "Subtitle file not found. Subtitle filename does not match file name from API call.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}

extension SearchTableViewController: ItemsDelegate {
    func refreshData(item: MediaItem) {
        print("refresh")
        self.mediaItems.append(item)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func setImage(item: MediaItem, data: Data) {
        print("imgrefresh")
        let i = mediaItems.index(of: item)
        mediaItems[i!].coverImage = UIImage(data: data)!
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

protocol SrtDelegate: class {
    func passSrtInfo(fileURL: URL, encoding: String, runtime: String)
}

