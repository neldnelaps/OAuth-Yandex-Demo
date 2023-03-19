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
        
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }

    private func updateData() {
        guard !token.isEmpty else {
            let requestTokenViewController = AuthViewController()
            requestTokenViewController.delegate = self
            present(requestTokenViewController, animated: false, completion: nil)
            return
        }
        
        var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources/files")
        components?.queryItems = [URLQueryItem(name: "media_type", value: "image")]
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
        
        guard let url = URL(string: currentItem.preview!) else {return cell}
        var request = URLRequest(url: url)
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request){ [weak self] (data, response, error) in
            guard let data = data else {return}
            DispatchQueue.main.async {
                cell.imageView?.image = UIImage(data: data)
            }
        }
        task.resume()
        
        cell.nameLabel?.text = currentItem.name
        cell.sizeLabel.text = ByteCountFormatter.string(fromByteCount: currentItem.size!, countStyle: .file)
        return cell
    }
}
