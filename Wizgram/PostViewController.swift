//
//  PostViewController.swift
//  Wizgram
//
//  Created by Dhiaa Bantan on 2/23/22.
//

import UIKit
import AlamofireImage
import Parse

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionTF: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    // When the post button is pressed:
    @IBAction func PostButtonPressed(_ sender: UIButton) {
        
        // Convert the image into binary file:
        let imageData = imageView.image!.pngData()
        let imageBin = PFFileObject(name: "image.png", data: imageData!)
        // Create a table for posts:
        let post = PFObject(className: "Posts")
        
        // Create an element (row) in the posts table:
        post["author"] = PFUser.current()!
        post["caption"] = captionTF.text
        post["image"] = imageBin
        
        // Save changes in the database:
        post.saveInBackground { success, error in
            
            if success {
                // If it is successful, dismiss the screen:
                self.dismiss(animated: true, completion: nil)
            } else {
                // If there is an error, print it:
                print(error?.localizedDescription)
            }
        }
        
        
    }
    
    // When the image view is tapped:
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        
        // Create the image picker:
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        // If the access to camera is available use the camera, otherwise use the photo library:
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    
    // Function to pick the selected image:
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Scale the selected image:
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageScaled(to: size)
        
        // Display the scaled image on the image view
        imageView.image = scaledImage
        
        // Dismiss the current screen:
        dismiss(animated: true, completion: nil)
    }
    
    
}
