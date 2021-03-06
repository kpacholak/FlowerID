//
//  FlowerManager.swift
//  FlowerID
//
//  Created by Krzysztof Pacholak on 05/03/2021.
//

import Foundation

protocol FlowerManagerDelegate {
    func didUpdateFlower(extract: String, imageSrcURL: String)
    func didFailWithError()
}

class FlowerManager {
    
    var delegate: FlowerManagerDelegate?
    
    func fetchData(flowerName: String) {
        print("entering fetchData")
        let urlString = "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts%7Cpageimages&pithumbsize=500&exintro&explaintext&redirects=1&titles=\(flowerName)"
        
        performRequest(urlString)
    }
    
    func performRequest(_ urlString: String) {
        print("entering performRequest")
        print("urlString = \(urlString)")
        if let url = URL(string: urlString) {
            print("entering url")
            let session = URLSession(configuration: .default)
            print("entering session")
            let task = session.dataTask(with: url) { (data, response, error) in
                print("entering task")
                if error != nil {
                    return
                }
                
                if let safeData = data {
                    print("calling parseJSON")
                    self.parseJSON(flowerData: safeData)
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(flowerData: Data) {
        print("entering parseJSON")
        let decoder = JSONDecoder()
        do {
            
            let decodedData = try decoder.decode(FlowerIDModel.self, from: flowerData).query.pages
            print(decodedData)
            //changing dictionary key captured here
            if let pageKey = decodedData.first?.key {
                print(pageKey)
                // dictionary that the changing key refers to
                let results = decodedData[pageKey]!
                print(results)
                self.delegate?.didUpdateFlower(extract: results.extract, imageSrcURL: results.thumbnail.source)
            }
        } catch {
            print("error found: \(error)")
            self.delegate?.didFailWithError()
        }
    }
}
