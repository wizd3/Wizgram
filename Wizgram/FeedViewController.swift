//
//  FeedViewController.swift
//  Wizgram
//
//  Created by Dhiaa Bantan on 2/23/22.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var postTableView: UITableView!
    
    // Create an array of PFObjects:
    var posts = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        postTableView.delegate = self
        postTableView.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Create a query:
        let query = PFQuery(className: "Posts")
        // Get the actuall object not only the pointer:
        query.includeKey("author")
        // Set the limit:
        query.limit = 20
        
        query.findObjectsInBackground { database_posts, error in
            if database_posts != nil {
                // If there are posts, retrieve posts and reload the table view:
                self.posts = database_posts!
                self.postTableView.reloadData()
                
            } else {
                // If there is an error, print it:
                print(error?.localizedDescription)
            }
        }
        
    }
    
    // Number of table view rows:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count
    
    }
    
    // Populate the table view with cells:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell:
        let cell = postTableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        // Extract the post information:
        let post = posts[indexPath.row]
        let user = post["author"] as! PFUser
        
        // Set the cell elements:
        cell.usernameLabel.text = user.username
        cell.captionLabel.text = post["caption"] as? String
        
        // Set the image:
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let URL = URL(string: urlString)!
        cell.photoView.af.setImage(withURL: URL)
        
        return cell
    }

}
