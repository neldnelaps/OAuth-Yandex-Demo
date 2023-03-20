//
//  FilesViewModel.swift
//  OAuthYandexDemo
//
//  Created by Natalia Pashkova on 20.03.2023.
//

import Foundation
import RxSwift
import RxCocoa

class FilesViewModel {
    var files = BehaviorSubject(value: [DiskFile]())
    var token: String = ""
    
    func fetchFiles() {
        guard !token.isEmpty else {return}
        
        var components = URLComponents(string: "\(ClientAPI.cloadApiYandex)v1/disk/resources/files")
        components?.queryItems = [
            URLQueryItem(name: "media_type", value: "image"),
            URLQueryItem(name: "limit", value: "1000")]
        
        guard let url = components?.url else {return}
        var request = URLRequest(url: url)
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request){ [weak self] (data, response, error) in
            guard let self = self, let data = data else {return}
            do {
                guard let newFiles = try?  JSONDecoder().decode(DiskResponse.self, from: data) else {return}
                self.files.on(.next(newFiles.items!))
            }
            catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func uploadFile(){
        var components = URLComponents(string: "\(ClientAPI.cloadApiYandex)v1/disk/resources/upload")
        components?.queryItems = [
            URLQueryItem(name: "url", value: "https://imgv3.fotor.com/images/blog-cover-image/part-blurry-image.jpg"),
            URLQueryItem(name: "path", value: "item")
        ]
        guard let url = components?.url else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request){ [weak self] (data, response, error) in
            if let response = response as? HTTPURLResponse{
                switch response.statusCode {
                case 200..<300:
                    print("Success")
                    self?.fetchFiles()
                default:
                    print("Status: \(response.statusCode)")
                }
            }
        }.resume()
    }
}
