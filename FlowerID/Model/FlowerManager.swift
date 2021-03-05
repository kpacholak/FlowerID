//
//  FlowerManager.swift
//  FlowerID
//
//  Created by Krzysztof Pacholak on 05/03/2021.
//

import Foundation

protocol FlowerManagerDelegate {
    func didUpdateFlower(extract: String, imageSrcURL: String)
    func didFailWithError(error: Error)
}

class FlowerManager {
    
    var delegate: FlowerManagerDelegate?
    
    func fetchData(flowerName: String) {
        
        let urlString = "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts%7Cpageimages&pithumbsize=500&exintro&explaintext&redirects=1&titles=\(flowerName)"
        
        performRequest(urlString)
    }
    
    func performRequest(_ urlString: String) {
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                
                if error != nil {
                    return
                }
                
                if let safeData = data {
                    self.parseJSON(flowerData: safeData)
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(flowerData: Data) {
        
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(FlowerIDModel.self, from: flowerData).query.pages
            //changing dictionary key captured here
            if let pageKey = decodedData.first?.key {
                // dictionary that the changing key refers to
                let results = decodedData[pageKey]!
                self.delegate?.didUpdateFlower(extract: results.extract, imageSrcURL: results.thumbnail.source)
            }
        } catch {
            print(error)
        }
    }
}
