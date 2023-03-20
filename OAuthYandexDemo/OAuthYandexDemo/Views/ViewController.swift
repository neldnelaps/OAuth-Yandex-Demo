//
//  ViewController.swift
//  OAuthYandexDemo
//
//  Created by Natalia Pashkova on 18.03.2023.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    lazy var tableView : UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        let textCell = UINib(nibName: "FileTableViewCell", bundle: nil)
        tv.register(textCell, forCellReuseIdentifier: "FileTableViewCell")
        return tv
    }()
    private var isFirst = true
    private var token: String = ""
    
    private var filesData: DiskResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirst {
            updateData()
        }
        isFirst = false
    }
    
    private func setupViews() {
        view.backgroundColor =  .white
        title = "Мои фото"
        
        let addNewFile = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(uploadFile))
        self.navigationItem.rightBarButtonItem = addNewFile
        
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }
    
    @objc private func uploadFile(){
        var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources/upload")
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
                    self?.updateData()
                default:
                    print("Status: \(response.statusCode)")
                }
            }
        }.resume()
    }

    private func updateData() {
        guard !token.isEmpty else {
            let requestTokenViewController = AuthViewController()
            requestTokenViewController.delegate = self
            present(requestTokenViewController, animated: false, completion: nil)
            return
        }
        
        var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources/files")
        components?.queryItems = [
            URLQueryItem(name: "media_type", value: "image"),
            URLQueryItem(name: "limit", value: "1000")]
        
        guard let url = components?.url else {return}
        var request = URLRequest(url: url)
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request){ [weak self] (data, response, error) in
            guard let self = self, let data = data else {return}
            guard let newFiles = try?  JSONDecoder().decode(DiskResponse.self, from: data) else {return}
            self.filesData = newFiles
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
        task.resume()
    }
}

extension ViewController : AuthViewControllerDelegate {
    func handleTokenChanged (token: String) {
        self.token = token
        print("New token: \(token)")
        updateData()
    }
}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filesData?.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileTableViewCell", for: indexPath) as! FileTableViewCell
        guard let items = filesData?.items, items.count > indexPath.row else {return cell}
        let currentItem = items[indexPath.row]
        
        cell.delegate = self
        cell.delegate?.loadImage(stringUrl: currentItem.preview!, completion: { image in
            cell.fileImageView.image = image
        })
        cell.nameLabel?.text = currentItem.name
        cell.sizeLabel.text = ByteCountFormatter.string(fromByteCount: currentItem.size!, countStyle: .file)
        return cell
    }
}

extension ViewController : FileTableViewCellDelegate{
    func loadImage(stringUrl: String, completion: @escaping ((UIImage?) -> Void)) {
        guard let url = URL(string: stringUrl) else {return}
        var request = URLRequest(url: url)
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request){ [weak self] (data, response, error) in
            guard let data = data else {return}
            DispatchQueue.main.async {
                completion(UIImage(data: data))
            }
        }
        task.resume()
    }
}
