//
//  ViewController.swift
//  File upload sample
//
//  Created by Divakar Murugesh on 28/01/20.
//  Copyright © 2020 Divakar Murugesh. All rights reserved.
//

import UIKit
import MobileCoreServices
import Alamofire

class ViewController: UIViewController, UIDocumentPickerDelegate {
    
    @IBOutlet weak var lblFileName: UILabel!
    @IBOutlet weak var btnUpload: UIButton!
    
    var postData: Data? = nil
    var fileName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        btnUpload.isEnabled = (postData != nil)
    }
    
    @IBAction func clickedFileChooser(_ sender: Any) {
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: [String(kUTTypeAudio)], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .fullScreen
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction func clickedFileUpload(_ sender: Any) {
        
        uploadWithAlamofire()
        
    }
    
    func uploadWithAlamofire() {
        
        // define parameters
        let parameters = [
            "key1": "value1",
            "key2": "value2"
        ]
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                
                if let postData = self.postData {
                    multipartFormData.append(postData, withName: "file", fileName: self.fileName, mimeType: "audio/mpeg")
                }
                
                for (key, value) in parameters {
                    multipartFormData.append((value.data(using: .utf8))!, withName: key)
                }
        },
            to: "http://101.0.70.50:7979/audio?userid=2&duration=00:00:20&filename=\(fileName)",
            method: .post,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.response { [weak self] response in
                        guard self != nil else {
                            return
                        }
                        debugPrint(response)
                        debugPrint(response.response ?? "")
                        debugPrint(response.response?.statusCode ?? "")
                        
                        do {
                            if response.data != nil {
                                let json = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers)
                                debugPrint(json)
                                
                                let alert = UIAlertController(title: "Success", message: "Response from server : \n\(json)", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                                self?.present(alert, animated: true, completion: nil)
                            }
                        } catch {
                            debugPrint(error)
                        }
                    }
                case .failure(let encodingError):
                    print("error:\(encodingError)")
                }
        })
    }
    
    // MARK: - UIDocumentPickerDelegate
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
        print("picker cancelled!!")
        
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        print("picker completed \(urls)")
        
        lblFileName.text = urls.first?.path
        
        postData = FileManager.default.contents(atPath: urls.first?.path ?? "")
        
        fileName = urls.first?.lastPathComponent ?? ""
        
        debugPrint("post Data = \(postData)")
        debugPrint("file Name = \(fileName)")
        
        btnUpload.isEnabled = (postData != nil)
    }
}
