//
//  AuthViewModel.swift
//  OAuthYandexDemo
//
//  Created by Natalia Pashkova on 20.03.2023.
//

import Foundation

class AuthViewModel {
    var request : URLRequest? {
        guard var urlComponents = URLComponents(string: ClientAPI.oauthYandex) else {return nil}
        urlComponents.queryItems = [
        URLQueryItem(name: "response_type", value: "token"),
        URLQueryItem(name: "client_id", value: "\(ClientAPI.clientId)")]
        
        //https://oauth.yandex.com/authorize?response_type=token&client_id=<id>
        guard let url = urlComponents.url else {return nil}
        return URLRequest(url: url)
    }
}
