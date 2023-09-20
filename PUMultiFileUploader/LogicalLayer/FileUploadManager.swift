//
//  FileUploadManager.swift
//  PUMultiFileUploader
//
//  Created by Payal on 15/09/23.
//

import Foundation
import Alamofire
enum FileUploadStatus: String
{
    case  notStarted
    case pause
    case uploading
    case failed
    case completed
}
class FileUploadManager : NSObject {
    // MARK : Variables Declaration
    var id: String?
    var imgData : Data?
    var imgname: String?
    var imgSize:Double = 0.0
    typealias MultiImgFileUpload = () -> Void
    var progress: Double? {
        didSet {
            DispatchQueue.main.async {
                self.progressBlock?(self.progress)
            }
        }
    }
    var uploadStatus: FileUploadStatus = .notStarted
    var progressBlock: ((Double?)->())?
    
    private weak var uploadTask: UploadRequest?
    
    // MARK : Data Init Implementation
    convenience init(id: String ,imgData: Data ,iname:String,isize:Double) {
        self.init()
        self.id = id
        self.imgData = imgData
        self.imgname = iname
        self.imgSize = isize
    }
    private override init() {}
    func pauseTask(){
        self.uploadStatus = .pause
        self.uploadTask?.suspend()
    }
    func resume(){
        self.uploadStatus = .uploading
        self.uploadTask?.resume()
    }
    func cancelUpload() {
        self.uploadStatus = .failed
        self.uploadTask?.cancel()
    }
    
    func uploadImgFile(mimeType:String = "image/png",fileName:String = "\(UUID().uuidString).png",completionHandler: @escaping (Data , [String:Any]?, Error?, Bool) -> Void)
    {
        if let galleyImgData = imgData {
            self.uploadStatus = .uploading
            DispatchQueue.global(qos: .background).async {
                let headersData : HTTPHeaders = [
                    "Content-Type": "application/json"
                    //add header data here if others
                ]
                let apiurl = "" // enter api url here
                self.uploadTask = AF.upload(multipartFormData: { multiPart in multiPart.append(galleyImgData, withName: "Files", fileName:fileName, mimeType: mimeType)}, to:  apiurl , method: .post, headers: headersData) .uploadProgress(queue: .main, closure:{ progress in
                    self.uploadStatus = .uploading
                    self.progressBlock?(progress.fractionCompleted) }).response
                { (response) in
                    switch response.result {
                    case .success(let result):
                        if let getdata = result{
                            do {
                                if let jsonResponse = try JSONSerialization.jsonObject(with: getdata, options : .allowFragments) as? [String:Any] {
                                    self.uploadStatus = .completed
                                    completionHandler(getdata, jsonResponse, nil, true)
                                }
                            } catch let error as NSError {
                                print(error)
                            }
                        }
                    case .failure(let err):
                        self.uploadStatus = .failed
                        completionHandler(Data(), nil, err, false)
                    }
                }
            }
        }
    }
}
