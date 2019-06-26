//
//  PostListViewController.swift
//  Post
//
//  Created by Albert Yu on 6/24/19.
//  Copyright © 2019 AlbertLLC. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var postController = PostController()
    @IBOutlet weak var postListTableView: UITableView!
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postController.fetchPosts{
            self.reloadTableView()
        }
        self.postListTableView.delegate = self
        self.postListTableView.dataSource = self
        self.postListTableView.estimatedRowHeight = 45
        self.postListTableView.rowHeight = UITableView.automaticDimension
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        displayAddPostController()
        refreshControlPulled()
    }


    func reloadTableView() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.postListTableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        let post = postController.posts[indexPath.row]
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "\(post.username) - " + "\(post.date ?? "")"
        return cell
    }
    
    @objc func refreshControlPulled() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        postController.fetchPosts {
            self.reloadTableView()
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
}


extension PostListViewController {
    func displayAddPostController(){
        let alertController = UIAlertController(title: "Add Post", message: "Only dirty comments allowed", preferredStyle: .alert)
        alertController.addTextField {(textField) in
            textField.placeholder = "Username"
        }
        alertController.addTextField {(textField) in
            textField.placeholder = "Message"
        }
        let addPostItemAction = UIAlertAction(title: "Add", style: .default) { (_) in
            guard let postUsername = alertController.textFields?.first?.text, postUsername != " ", let postMessage = alertController.textFields?.last?.text, postMessage != " " else {return}
            self.postController.addNewPostWith(username: postUsername, text: postMessage, completion: {
                self.reloadTableView()
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(addPostItemAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
        self.postListTableView.reloadData()
        
    }
}
