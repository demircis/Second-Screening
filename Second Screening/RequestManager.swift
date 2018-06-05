//
//  RequestManager.swift
//  Second Screening
//
//  Created by Sinan Demirci on 21.05.18.
//  Copyright © 2018 Sinan Demirci. All rights reserved.
//

import UIKit

class RequestManager: NSObject {
    
    let baseURL: String = "https://rest.opensubtitles.org"
    let baseURLCover: String = "https://www.omdbapi.com/"
    let authkey: String = "b556a688"
    
    var urlConfig = URLSessionConfiguration.default
    var urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default)
    var dataTask: URLSessionDataTask?
    var dataTaskCover: URLSessionDataTask?
    var urlSessionCover: URLSession = URLSession(configuration: .default)
    
    var errorMessage: String = "SEARCH"
    
    var mediaItemsDelegate: ItemsDelegate?
    
    init(delegate: ItemsDelegate?) {
        self.mediaItemsDelegate = delegate
        self.urlConfig.httpAdditionalHeaders = ["User-Agent" : "Second Screening/v1"]
        self.urlSession = URLSession(configuration: urlConfig)
    }
    
    func buildQuery(searchBar: UISearchBar) -> String {
        var query: String = searchBar.text!
        query = query.replacingOccurrences(of: " ", with: "%20")
        query = "/search/query-" + query + "/sublanguageid-eng"
        return query
    }
    
    func sendSubtitlesRequest(searchBar: UISearchBar) {
        let options: String = self.buildQuery(searchBar: searchBar)
        dataTask?.cancel()
        if var urlComponents = URLComponents(string: baseURL) {
            urlComponents.path = options
            guard let url = urlComponents.url else { return }
            dataTask = urlSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                
                if let error = error {
                    self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                    print(self.errorMessage)
                } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                        if !json.isEmpty {
                            self.parseJsonResponse(jsonSubtitles: json)
                        }
                    } catch let jsonError as NSError {
                        print(jsonError.localizedDescription)
                    }
                    
                } else {
                    print("DT 404/3 error")
                }
            }
            dataTask?.resume()
        } else {
            print("else branch")
        }
    }
    
    func fetchCoverImage(item: MediaItem, completion:@escaping (URL,MediaItem) -> Void) {
        let apikey = URLQueryItem(name: "apikey", value: authkey)
        let media = URLQueryItem(name: "i", value: item.imdbID)
        if var urlComponents = URLComponents(string: baseURLCover) {
            urlComponents.queryItems = [apikey, media]
            
            guard let url = urlComponents.url else { return }
            dataTaskCover = urlSessionCover.dataTask(with: url) { data, response, error in
                defer { self.dataTaskCover = nil }
                
                if let error = error {
                    self.errorMessage += "DataTaskCover error: " + error.localizedDescription + "\n"
                    print(self.errorMessage)
                } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                        if !json.isEmpty {
                            let urlString = json["Poster"] as? String
                            if urlString != nil {
                                let imgUrl = URL(string: urlString!)
                                completion(imgUrl!, item)
                                print("Fetch Task: " + "\(imgUrl!)")
                            }
                        }
                    } catch let jsonError as NSError {
                        print(jsonError.localizedDescription)
                    }
                    
                } else {
                    print("DTC 404/3 error")
                }
            }
            dataTaskCover?.resume()
        }
    }
    
    func startDownloadTask(url: URL, item: MediaItem) {
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            // callback
            self.mediaItemsDelegate?.setImage(item: item, data: data)
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func parseJsonResponse(jsonSubtitles: [[String: Any]]) {
        var titleEpisodeParser: NSRegularExpression
        do {
            titleEpisodeParser = try NSRegularExpression(pattern: "(\"[\\s\\S]*\") ([\\s\\S]*)")
            for item in jsonSubtitles {
                var mediaInfo = MediaInformation(type: "", imdbID: "", runtime: "", seasonAndEpisode: "", cover: #imageLiteral(resourceName: "mediaPlaceholder"), title: "", episodeTitle: "", subtitle: "", fileName: "", encoding: "", link: "")
                mediaInfo.type = "\(item["MovieKind"]!)"
                if mediaInfo.type.elementsEqual("movie") {
                    mediaInfo.imdbID = "tt" + String(format: "%07d", Int("\(item["IDMovieImdb"]!)")!)
                    mediaInfo.title = "\(item["MovieName"]!) (\(item["MovieYear"]!))"
                } else {
                    mediaInfo.imdbID = "tt" + String(format: "%07d", Int("\(item["SeriesIMDBParent"]!)")!)
                    mediaInfo.seasonAndEpisode = "S\(item["SeriesSeason"]!)E\(item["SeriesEpisode"]!)"
                    let gotTitle = "\(item["MovieName"]!)"
                    let matcher = titleEpisodeParser.matches(in: gotTitle, options: [], range: NSMakeRange(0, gotTitle.count))
                    mediaInfo.title = String(gotTitle[Range((matcher[0].range(at: 1)), in: gotTitle)!]) + " (\(item["MovieYear"]!))"
                    mediaInfo.episodeTitle = String(gotTitle[Range((matcher[0].range(at: 2)), in: gotTitle)!])
                }
                mediaInfo.runtime = "\(item["SubLastTS"]!)"
                mediaInfo.subtitle = "\(item["MovieReleaseName"]!)"
                mediaInfo.fileName = "\(item["SubFileName"]!)"
                mediaInfo.encoding = "\(item["SubEncoding"]!)"
                mediaInfo.link = "\(item["SubDownloadLink"]!)"
                let it = MediaItem(info: mediaInfo)
                print("completion")
                self.mediaItemsDelegate?.refreshData(item: it)
                fetchCoverImage(item: it, completion: startDownloadTask)
            }
        } catch {
            print("regex error")
        }

    }
}

protocol ItemsDelegate: class {
    func refreshData(item: MediaItem)
    func setImage(item: MediaItem, data: Data)
}
