//
//  ViewController.swift
//  OAuthYandexDemo
//
//  Created by Natalia Pashkova on 18.03.2023.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa

class FilesViewController: UIViewController {
    private var viewModel = FilesViewModel()
    private var bag = DisposeBag()
    
    lazy var tableView : UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        let textCell = UINib(nibName: "FileTableViewCell", bundle: nil)
        tv.register(textCell, forCellReuseIdentifier: "FileTableViewCell")
        return tv
    }()
    private var isFirst = true
    private var filesData: DiskResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        if isFirst {
            let requestTokenViewController = AuthViewController()
            requestTokenViewController.delegate = self
            present(requestTokenViewController, animated: false, completion: nil)
            viewModel.fetchFiles()
            bindTableView()
        }
        isFirst = false
    }

    func bindTableView() {
        tableView.rx.setDelegate(self).disposed(by: bag)
        viewModel.files.bind(to: tableView.rx.items(cellIdentifier: "FileTableViewCell", cellType: FileTableViewCell.self)) {
            (row, item, cell) in
            cell.delegate = self
            cell.delegate?.loadImage(stringUrl: item.preview!, completion: { image in
                cell.fileImageView.image = image
            })
            cell.nameLabel?.text = item.name
            cell.sizeLabel.text = ByteCountFormatter.string(fromByteCount: item.size!, countStyle: .file)

        }.disposed(by: bag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupViews() {
        view.backgroundColor =  .white
        title = "Мои фото"
        
        let addNewFile = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(uploadFile))
        self.navigationItem.rightBarButtonItem = addNewFile

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }
    
    @objc private func uploadFile(){
        viewModel.uploadFile()
    }
}

extension FilesViewController : UITableViewDelegate {

}

extension FilesViewController : AuthViewControllerDelegate {
    func handleTokenChanged (token: String) {
        self.viewModel.token = token
        print("New token: \(token)")
        viewModel.fetchFiles()
    }
}

extension FilesViewController : FileTableViewCellDelegate{
    func loadImage(stringUrl: String, completion: @escaping ((UIImage?) -> Void)) {
        guard let url = URL(string: stringUrl) else {return}
        var request = URLRequest(url: url)
        request.setValue("OAuth \(viewModel.token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request){ [weak self] (data, response, error) in
            guard let data = data else {return}
            DispatchQueue.main.async {
                completion(UIImage(data: data))
            }
        }
        task.resume()
    }
}
