//
//  PostController.swift
//  Post
//
//  Created by Albert Yu on 6/24/19.
//  Copyright © 2019 AlbertLLC. All rights reserved.
//

import Foundation

class PostController {
    
    var posts: [Post] = []
    let baseURL = URL(string: "http://devmtn-posts.firebaseio.com/posts")
    
    func fetchPosts(reset: Bool = true, completion: @escaping() -> Void) {
        
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.timestamp ?? Date().timeIntervalSince1970
        let urlParameters = [ "orderBy": "\"timestamp\"", "endAt": "\(queryEndInterval)", "limitToLast": "15", ]
  
        guard let url = baseURL else { completion(); return }
        let getterEndpoint = url.appendingPathExtension("json")
        var urlRequest = URLRequest(url: getterEndpoint)
        let queryItems = urlParameters.compactMap( { URLQueryItem(name: $0.key, value: $0.value) } )
        
        urlRequest.httpBody = nil
        urlRequest.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                print(error)
                completion()
                return
            }
            guard let data = data else {completion(); return}
            do {
                let jdecoder = JSONDecoder()
                let postsDictionary = try jdecoder.decode([String: Post].self, from: data)
                let posts = postsDictionary.compactMap({ $0.value })
                let sortedPosts = posts.sorted(by: { $0.timestamp > $1.timestamp })
                if reset {
                    self.posts = sortedPosts
                } else {
                    self.posts.append(contentsOf: sortedPosts)
                }
                completion()
            } catch {
                print(error.localizedDescription)
                completion()
                return
            }
        }
        dataTask.resume()
    }
    
    func addNewPostWith(username: String, text: String, completion: @escaping () -> Void ) {
        let post = Post(username: username, text: text)
        var postData: Data
        
        
        guard let url = baseURL else { completion(); return }
        let postEndpoint = url.appendingPathExtension("json")
        var urlRequest = URLRequest(url: postEndpoint)
        
        do {
            let jsonEncoder = JSONEncoder()
            postData = try jsonEncoder.encode(post)
        } catch {
            print("\(error)")
            completion()
            return
        }
        
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = postData
        
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
                completion() ; return
            }
            
            if let data = data {
                let dataString = String(data: data, encoding: .utf8)
            }
            self.fetchPosts(completion: {
                completion()
            })
        }
        dataTask.resume()
    }
}





