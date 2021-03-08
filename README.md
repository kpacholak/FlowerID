![FlowerID](Documentation/FlowerId_banner.png)

#  FlowerID



---

> FlowerID / simple camera-based tool to identify flowers and get some essential information from Wikipedia. Apple MLModel generated from Caffe open source model.


## Code example

It is a simple app, so there is no spectacular code example here. But this passing image to detect() function could be consider as a characteristic part of the app

```swift
func detect(image: CIImage) {
        
        // VNCoreModel comes from Vision library. We're loading model
        let config = MLModelConfiguration()
        guard let coreMLModel = try? FlowerClassifier(configuration: config),
              let model = try? VNCoreMLModel(for: coreMLModel.model) else { fatalError("Loading CoreML Model Failed") }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let classification = request.results?.first as? VNClassificationObservation else { fatalError("Unable to classify image") }

            // result from classifictaion goes to navigation title (capitalized)
            self.navigationItem.title = classification.identifier.capitalized
            let flowerStringName = self.navigationItem.title?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)
            self.flowerManager.fetchData(flowerName: flowerStringName ?? "rose")
            
            if let flowerSafeName = self.navigationItem.title {
                self.flowerName = flowerSafeName
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
```



## Status
Project is _in progress_

Things to do:
* save favourites feature
* share feature
* implement tableView

## Inspiration
Project inspired by Angela's Yu app.

## Contact
Created by [@pacholak](https://twitter.com/pacholak) - feel free to contact me!

## License
[MIT](https://choosealicense.com/licenses/mit/)
