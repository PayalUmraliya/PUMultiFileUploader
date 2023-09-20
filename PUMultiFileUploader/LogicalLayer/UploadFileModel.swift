//
//  UploadFileModel.swift
//  PUMultiFileUploader
//
//  Created by Payal on 14/09/23.
//

import Foundation
import Alamofire

struct UploadFileModel: Codable {
    let code : Int?
    let msg : String?
    let data : Data?
    let error : String?
    
    enum CodingKeys: String, CodingKey {
        
        case code = "code"
        case msg = "msg"
        case data
        case error = "error"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decodeIfPresent(Int.self, forKey: .code)
        msg = try values.decodeIfPresent(String.self, forKey: .msg)
        data = try values.decodeIfPresent(Data.self, forKey: .data)
        error = try values.decodeIfPresent(String.self, forKey: .error)
    }
    
    struct Data : Codable {
        let virtualPath : String?
        let physicalPath : String?
        
        enum CodingKeys: String, CodingKey {
            
            case virtualPath = "virtualPath"
            case physicalPath = "physicalPath"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            virtualPath = try values.decodeIfPresent(String.self, forKey: .virtualPath)
            physicalPath = try values.decodeIfPresent(String.self, forKey: .physicalPath)
        }
    }
}
