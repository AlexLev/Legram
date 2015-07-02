//
//  AddContentViewController.swift
//  Legram
//
//  Created by Алексей Левинтов on 28.06.15.
//  Copyright (c) 2015 Алексей Левинтов. All rights reserved.
//

import UIKit
import Parse
class AddContentViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var contentText: UITextView!
    @IBOutlet weak var contentImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        contentText.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func choiceContent(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
            println("Button capture")
            var imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            //imag.mediaTypes = [kUTTypeImage];
            imag.allowsEditing = false
            self.presentViewController(imag, animated: true, completion: nil)
        }
    }
    @IBAction func sentContent(sender: AnyObject) {
        let imageFile = PFFile(name: nil, data:UIImagePNGRepresentation(contentImage.image), contentType: nil)
        let content = PFObject(className: "Content", dictionary: ["image" : imageFile, "fromUser":PFUser.currentUser()!, "text":contentText.text])
        content.saveInBackgroundWithBlock { (successed, error) -> Void in
//            textField.enabled = true
            if successed {
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        let selectedImage : UIImage = image
        //var tempImage:UIImage = editingInfo[UIImagePickerControllerOriginalImage] as UIImage
        contentImage.image=selectedImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "введите текст" {
           textView.text = ""
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
