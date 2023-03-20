//
//  AuthViewController.swift
//  OAuthYandexDemo
//
//  Created by Natalia Pashkova on 18.03.2023.
//

import UIKit
import Foundation
import WebKit
import RxSwift
import RxCocoa

public protocol AuthViewControllerDelegate : class {
    func handleTokenChanged (token: String)
}

final class AuthViewController : UIViewController{
    private var viewModel = AuthViewModel()
    private var bag = DisposeBag()
    
    weak var delegate : AuthViewControllerDelegate?
    private let webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        guard let request = self.viewModel.request else {return}
        webView.load(request)
        webView.navigationDelegate = self
    }
    
    func setupViews() {
        view.backgroundColor =  .white
        title = "Мои фото"
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }
}

extension AuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url,
            url.scheme == "myphotos" {
            let targetString =  url.absoluteString.replacingOccurrences(of: "#", with: "?")
            guard let components = URLComponents(string: targetString) else {return}
            let token = components.queryItems?.first(where: {$0.name == "access_token"})?.value
            if let token = token {
                delegate?.handleTokenChanged(token: token)}
            
            dismiss(animated: true, completion: nil)
        }
        decisionHandler(.allow)
    }
}
