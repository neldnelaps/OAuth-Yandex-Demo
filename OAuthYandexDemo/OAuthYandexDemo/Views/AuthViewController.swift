//
//  AuthViewController.swift
//  OAuthYandexDemo
//
//  Created by Natalia Pashkova on 18.03.2023.
//

import UIKit
import Foundation
import WebKit

public protocol AuthViewControllerDelegate : class {
    func handleTokenChanged (token: String)
}

final class AuthViewController : UIViewController{
    weak var delegate : AuthViewControllerDelegate?
    private let webView = WKWebView()
    private let clientId = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        guard let request = self.request else {return}
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
    
    private var request : URLRequest? {
        guard var urlComponents = URLComponents(string: "http://oauth.yandex.ru/authorize") else {return nil}
        urlComponents.queryItems = [
        URLQueryItem(name: "response_type", value: "token"),
        URLQueryItem(name: "client_id", value: "\(clientId)")]
        
        //https://oauth.yandex.com/authorize?response_type=token&client_id=<id>
        guard let url = urlComponents.url else {return nil}
        return URLRequest(url: url)
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
