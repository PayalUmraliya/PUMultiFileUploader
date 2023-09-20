//
//  ViewController.swift
//  PUMultiFileUploader

import UIKit
import Foundation
import Alamofire
extension UIViewController
{
    func presentAlertController(with message: String) {
      let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
      present(alert, animated: true)
    }
}
class ViewController: UIViewController {
    @IBOutlet weak var tblDoc: UITableView!
    var ImgsUploadArr = [FileUploadManager]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblDoc.register(UINib(nibName: "UploadingDocCell", bundle: nil), forCellReuseIdentifier: "UploadingDocCell")
    }
    
    @IBAction func didTapBrowse(_ sender: Any) {
        let vc = FilePickerVC(nibName: "FilePickerVC", bundle: nil)
        vc.modalPresentationStyle = .overCurrentContext
        vc.didselectFileArr = {(selectedFiles) in
            self.ImgsUploadArr = selectedFiles
            self.tblDoc.reloadData()
        }
        self.present(vc, animated: false, completion: nil)
    }
}
extension ViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.ImgsUploadArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UploadingDocCell", for: indexPath) as? UploadingDocCell else { return UITableViewCell() }
             if self.ImgsUploadArr.count > 0 {
                let fileUpload = self.ImgsUploadArr[indexPath.row]
                 cell.imgSelected.image = UIImage.init(data: fileUpload.imgData ?? Data())
                 cell.lblDocname.text = fileUpload.imgname ?? ""
                 
                 cell.uploadProgress.isHidden = false
                fileUpload.progressBlock = { (pro) in
                    print( "\(fileUpload.imgname ?? "") -  \(Float(pro ?? 0.0))")
                    cell.uploadProgress.progress = Float(pro ?? 0.0)
                    let prgress = (Float(pro ?? 0.0) )/100
                    cell.lblStatus.text = fileUpload.uploadStatus == .uploading ? "Uploading \(prgress)" : ""
              }
              fileUpload.uploadImgFile { (fileUploadGet, response, error, status) in
                  do {
                      let jsonDecoder = JSONDecoder()
                      let uploadModel = try jsonDecoder.decode(UploadFileModel.self, from:  fileUploadGet)
                      
                      if uploadModel.code == 1 {
                          cell.uploadProgress.isHidden = true
                          cell.lblStatus.text = "Upload Success...."
                      } else {
                          cell.uploadProgress.isHidden = false
                          cell.lblStatus.text = "Upload Failed...."
                      }
                  } catch {
                      cell.uploadProgress.isHidden = false
                      cell.lblStatus.text = "Upload Failed...."
                  }
              }
        }
       return cell
    }
}
