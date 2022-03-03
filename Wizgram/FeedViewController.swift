//
//  FeedViewController.swift
//  Wizgram
//
//  Created by Dhiaa Bantan on 2/23/22.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    @IBOutlet weak var postTableView: UITableView!
    
    let commentBar = MessageInputBar()
    
    var showCommentBar: Bool = false
    var selectedPost: PFObject!
    
    // Create an array of PFObjects:
    var posts = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Configure the comment bar:
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        postTableView.delegate = self
        postTableView.dataSource = self
        
        // Dismiss the keyboard when scroll down the table view:
        postTableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillBeHidden(note: Notification){
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // Create the comment:
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
        
        // Add the comment:
        selectedPost.add(comment, forKey: "comments")
        
        // Save the changes to database:
        selectedPost.saveInBackground { success, error in
            if success {
                print("Comment saved")
            } else {
                print("Error saving comment")
            }
        }
        
        // Refresh table view:
        postTableView.reloadData()
        
        // Clear the comment bar:
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
        
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showCommentBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Create a query:
        let query = PFQuery(className: "Posts")
        // Get the actuall object not only the pointer:
        query.includeKeys(["author", "comments", "comments.author"])
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
    
    // Sign Out Button:
    @IBAction func SignOutButton(_ sender: UIBarButtonItem) {
        
        // Update the UserDefaults and remember that the user had logged out:
        UserDefaults.standard.set(false, forKey: "User_LoggedIn")
        
        // Navigate back to the root screen (Sign In/Up)
        dismiss(animated: true, completion: nil)
        
    }
    
    
    // Number of table view sections:
    func numberOfSections(in tableView: UITableView) -> Int {
        
        // One section per post:
        return posts.count
    }
    
    // Number of table view rows in each section:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Extract the comments related to each post:
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        // Add 1 for the image, 1 for the add comment:
        return comments.count + 2
    }
    
    // Populate the table view with cells:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        // If the indexPath row is the first row that means it is the post:
        if(indexPath.row == 0){
            // Configure the cell for posts:
            let cell = postTableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            // Extract the post information:
            let post = posts[indexPath.section]
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
        
        } else if (indexPath.row <= comments.count) {
            
            // Configure the cell for comments:
            let cell = postTableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.usernameLabel.text = user.username
            
            return cell
            
        } else {
            let cell = postTableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            
            
            return cell
        }
        
    }
    
    // Action when select a cell:
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Figure out which post is selected:
        let post = posts[indexPath.section]
        
        // Create a comment column on the database:
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if(indexPath.row == comments.count + 1) {
            showCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            // Remember which post:
            selectedPost = post
            
        }
        
    }
    
    
}
