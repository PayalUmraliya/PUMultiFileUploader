//
//  FilePickerVC.swift



import UIKit

import AssetsPickerViewController
import Photos
import MobileCoreServices




class FilePickerVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var vwBG: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblFolder: UILabel!
    @IBOutlet weak var lblGallery: UILabel!
    @IBOutlet weak var stCamera: UIStackView!
    @IBOutlet weak var lblCamera: UILabel!
    
    //MARK: - Constants
    var uploadSize: Double = 0.0
    var assetArr = [FileUploadManager]()
    lazy var imageManager = { return PHImageManager.default() }()
    var didselectFile: ((_ data:Data,_ fileName:String) -> ())?
    var didselectFileArr: ((_ allfiles:[FileUploadManager]) -> ())?
    //MARK: - View methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
            self.stCamera.isHidden = false
        }
        let _ = vwBG.transform.translatedBy(x: 0.0, y: vwBG.frame.height)
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
            self.vwBG.transform = .identity
        }) { (_) in
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.vwBG.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    
    //MARK: - IBActions
    @IBAction func btnFolderCLK(_ sender: UIButton) {
        self.openiCloud()
    }
    @IBAction func btnGalleryCLK(_ sender: UIButton) {
        self.openGallery()
    }
    @IBAction func btnCameraCLK(_ sender: UIButton) {
        self.openCamera()
    }
    @IBAction func btnCloseCLK(_ sender: UIButton) {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
            let _ = self.vwBG.transform.translatedBy(x: 0.0, y: self.vwBG.frame.height)
        }) { (_) in
            self.dismiss(animated: false)
        }
    }
    
    static func loadFromNib() -> FilePickerVC{
        let docPVC = FilePickerVC(nibName: "FilePickerVC", bundle: nil)
        return docPVC
    }
    
    func didSelectFileDissmiss(data:Data,fileName:String){
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
            let _ = self.vwBG.transform.translatedBy(x: 0.0, y: self.vwBG.frame.height)
        }) { (_) in
            self.dismiss(animated: false) {
                self.didselectFile?(data, fileName)
            }
        }
    }
    func didSelectFilesAndDissmiss(allfiles:[FileUploadManager]){
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
            let _ = self.vwBG.transform.translatedBy(x: 0.0, y: self.vwBG.frame.height)
        }) { (_) in
            self.dismiss(animated: false) {
                self.didselectFileArr?(allfiles)
            }
        }
    }
    
}


//MARK: - UIImagePickerController
extension FilePickerVC: UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    func openCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.camera
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func openGallery() {
        let picker = AssetsPickerViewController()
        picker.pickerDelegate = self
        let pickerConfig = AssetsPickerConfig()
        pickerConfig.albumIsShowHiddenAlbum = true
        pickerConfig.assetsMinimumSelectionCount = 1
        pickerConfig.assetsMaximumSelectionCount = 10
        
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        pickerConfig.assetFetchOptions = [ .smartAlbum: options, .album: options  ]
        picker.pickerConfig = pickerConfig
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        DispatchQueue.main.async {
            if let image = info[.originalImage] as? UIImage {
                let timeInterval = Date().timeIntervalSince1970
                var fileName = "Img_\(timeInterval)"
                fileName = fileName.replacingOccurrences(of: ".", with: "") + "ios.jpg"
                print("image selected name - \(fileName)")
                if let imageData = image.jpegData(compressionQuality: 1){
                    self.uploadSize = (Double(imageData.count) / (1024 * 1024))
                    if  self.uploadSize >= 10.0 {
                        self.presentAlertController(with:"Document cannot be greater than 10 mb")
                    
                    }else{
                        let objFileUpload = FileUploadManager(id: UUID().uuidString, imgData: imageData,iname: fileName,isize: self.uploadSize)
                        self.assetArr.removeAll()
                        self.assetArr.append(objFileUpload)
                        self.didSelectFilesAndDissmiss(allfiles: self.assetArr)
                    }
                }
            } else{
                self.presentAlertController(with:"Failed to upload image")
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
}

//MARK: - Assets PickerView Controller Delegate
extension FilePickerVC:AssetsPickerViewControllerDelegate {
    //Assets PickerViewController
    func assetsPicker(controller: AssetsPickerViewController, shouldSelect asset: PHAsset, at indexPath: IndexPath) -> Bool {
//        if controller.selectedAssets.count  > 0 { return false }
        return true
    }
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        let imageAssets = assets
        self.assetArr.removeAll()
        for singleImage in imageAssets {
           
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            let targetSize = CGSize(width: singleImage.pixelWidth, height: singleImage.pixelHeight)
            self.imageManager.requestImage(for: singleImage, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                if let imageData = image?.jpegData(compressionQuality: 1) {
                    let timeInterval = Date().timeIntervalSince1970
                    var fileName = "Img_\(timeInterval)"
                    fileName = fileName.replacingOccurrences(of: ".", with: "") + "ios.jpg"
                    print("image selected name - \(fileName)")
                    self.uploadSize = (Double(imageData.count) / (1024 * 1024))
                    if  self.uploadSize >= 10.0 {
                        self.presentAlertController(with:"Document cannot be greater than 10 mb")
                    }else{
                        print(fileName)
                        let objFileUpload = FileUploadManager(id: UUID().uuidString, imgData: imageData, iname: fileName,isize:self.uploadSize)
                     
                        self.assetArr.append(objFileUpload)
                        
                    }
                }
            })
        }
        if self.assetArr.count == imageAssets.count
        {
            self.didSelectFilesAndDissmiss(allfiles: assetArr)
        }
    }
}

//MARK: - Document picker delegate method
extension FilePickerVC: UIDocumentPickerDelegate {
    
    func openiCloud() {
        let types: NSArray = [kUTTypePDF as NSString,kUTTypeJPEG as String, kUTTypePNG,kUTTypeBMP as String,kUTTypeJPEG2000 as String]
        let documentPicker = UIDocumentPickerViewController(documentTypes: types as! [String], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    func thumbnailFromPdf(withUrl url:URL, pageNumber:Int, width: CGFloat = 240) -> UIImage? {
        guard let pdf = CGPDFDocument(url as CFURL),
            let page = pdf.page(at: pageNumber)
            else {
                return nil
        }
        
        var pageRect = page.getBoxRect(.mediaBox)
        let pdfScale = width / pageRect.size.width
        pageRect.size = CGSize(width: pageRect.size.width*pdfScale, height: pageRect.size.height*pdfScale)
        pageRect.origin = .zero
        
        UIGraphicsBeginImageContext(pageRect.size)
        let context = UIGraphicsGetCurrentContext()!
        
        // White BG
        context.setFillColor(UIColor.white.cgColor)
        context.fill(pageRect)
        context.saveGState()
        
        // Next 3 lines makes the rotations so that the page look in the right direction
        context.translateBy(x: 0.0, y: pageRect.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.concatenate(page.getDrawingTransform(.mediaBox, rect: pageRect, rotate: 0, preserveAspectRatio: true))
        
        context.drawPDFPage(page)
        context.restoreGState()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func gotDocumentUrl(docUrl: [URL]) {
        for url in docUrl {
            do {
                let documentData = try Data(contentsOf: url as URL)
//                let fileName = url.lastPathComponent.replacingOccurrences(of: " ", with: "_")
                let timeInterval = Date().timeIntervalSince1970
                let  fileName = "Doc_\(timeInterval)".replacingOccurrences(of: ".", with: "") + "ios." + url.pathExtension
                print("Document selected name - \(fileName)")
                self.uploadSize = (Double(documentData.count) / (1024 * 1024))
                if  self.uploadSize >= 10.0 {
                    self.presentAlertController(with:"Document cannot be greater than 10 mb")
                }else{
                    let objFileUpload = FileUploadManager(id: UUID().uuidString, imgData: documentData,iname: fileName,isize: self.uploadSize)
                    self.assetArr.removeAll()
                    self.assetArr.append(objFileUpload)
                    self.didSelectFilesAndDissmiss(allfiles: self.assetArr)
                }
            } catch {
                print("Catch gotDocumentUrl:\(error)")
                self.presentAlertController(with:"Catch gotDocumentUrl:\(error)")
            }
        }
    }
    
    //ios less than 11
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        var urls = [URL]()
        urls.append(url)
        gotDocumentUrl(docUrl: urls)
    }
    
    //ios greater than 11
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        gotDocumentUrl(docUrl: urls)
    }
}
