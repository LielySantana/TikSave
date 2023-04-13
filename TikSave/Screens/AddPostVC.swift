//
//  AddPostVC.swift
//  TikSave
//
//  Created by krunal on 25/02/23.
//

import UIKit
import UniformTypeIdentifiers
import AVFoundation
import UserNotifications
import PhotosUI

@available(iOS 15.0, *)
class AddPostVC: UIViewController{
    @IBOutlet weak var postCaption: UITextView!
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var timeTF: UITextField!
    @IBOutlet weak var selectedImgV: UIImageView!
    var imageFromVideo: String!
    var datePickerV = UIDatePicker()
    var timePickerV = UIDatePicker()
    var postsSchedule: [PostModel] = []
    var postData: PostModel!
    var delegate: PostListDelegate?
    let notificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationCenter.requestAuthorization(options: [.alert, .sound]){
            (permissionGranted, error) in
            if(!permissionGranted)
            {
                print("Permission Denied")
                let ac = UIAlertController(title: "Enable Notifications?", message: "To use this feature you must enable notifications in settings", preferredStyle: .alert)
                let goToSettings = UIAlertAction(title: "Settings", style: .default)
                { (_) in
                    guard let setttingsURL = URL(string: UIApplication.openSettingsURLString)
                    else
                    {
                        return
                    }
                    
                    if(UIApplication.shared.canOpenURL(setttingsURL))
                    {
                        UIApplication.shared.open(setttingsURL) { (_) in}
                    }
                }
                ac.addAction(goToSettings)
                ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in}))
                self.present(ac, animated: true)
            }
        }
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .authorized:
                print("Access granted")
            case .denied, .restricted:
                print("Access denied")
            case .notDetermined:
                print("Access not determined")
            @unknown default:
                fatalError("Unknown status")
            }
        }

        
            if let postData = postData {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM dd,yyyy, hh:mm a"
                let dateString = dateFormatter.string(from: postData.date!)
                var dateComponent = dateString.components(separatedBy: ", ")
                
                if let picData = postData.picData, let image = UIImage(data: picData) {
                    selectedImgV.image = image
                }
                
                dateTF.text = dateComponent[0]
                timeTF.text = dateComponent[1]
                postCaption.text = postData.caption
        }
        
        if (imageFromVideo != nil){
            self.selectedImgV.load(urlString: imageFromVideo)
        }

        
            let imgVGest = UITapGestureRecognizer(target:self, action: #selector(imgTapped))
            selectedImgV.isUserInteractionEnabled = true
            selectedImgV.addGestureRecognizer(imgVGest)
        
        
        setDatePicker()
        setTimePicker()
        
        dateChanged(sender: datePickerV)
        timeChanged(sender: timePickerV)
        
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePress))
        self.navigationItem.rightBarButtonItem = doneBtn
        
        
        print(delegate, "THIS IS THE POSTVC DELEGATE")
        
    }
    
        
    
    
    
    @objc func donePress(){
        if(!SharedService.shared.isPremium){
            guard let pro = self.storyboard?.instantiateViewController(withIdentifier: "ProVC") as? ProVC else {return}
            present(pro, animated: true)
        } else{
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleVC") as? ScheduleVC else {return}
            var postList = PostServices.shared.postList
            var newPost = PostModel(picData: selectedImgV.image?.pngData(), date: combineDateAndTime(datePicker: datePickerV, timePicker: timePickerV), caption: postCaption.text, uniqueID: "")
            print(newPost)
            
            notificationCenter.getNotificationSettings { (settings) in
                DispatchQueue.main.async {
                    let title = "Time to Post!"
                    let message = "Remember that you have a post scheduled"
                    
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = message
                    content.categoryIdentifier = "Dismissable"
                    
                    let dismissAction = UNNotificationAction(identifier: "dismiss", title: "Dismiss", options: [.destructive])
                    let category = UNNotificationCategory(identifier: "Dismissable", actions: [dismissAction], intentIdentifiers: [], options: [])
                    self.notificationCenter.setNotificationCategories([category])


                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM dd,yyyy, hh:mm a"
                    dateFormatter.timeZone = TimeZone.current
                    var selectedDate = "\(self.dateTF.text!), \(self.timeTF.text!)"
                    let date = dateFormatter.date(from: selectedDate)!
                    //                let date = substracHours(4, toDate: dateSet!)!
                    
                    if(settings.authorizationStatus == .authorized)
                    {
                        let content = UNMutableNotificationContent()
                        content.title = title
                        content.body = message
                        
                        
                        let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                        print(dateComp)
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
                        print(trigger)
                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                        
                        self.notificationCenter.add(request) { (error) in
                            if(error != nil)
                            {
                                print("Error scheduling notification: \(error!.localizedDescription)")
                                return
                            }else{
                                print("Scheduled")
                                newPost.uniqueID = request.identifier
                                       
                                if let postData = self.postData {
                                    if let index = postList.firstIndex(where: { $0.uniqueID == postData.uniqueID }) {
                                        postList[index] = newPost
                                        self.notificationCenter.removePendingNotificationRequests(withIdentifiers: [postData.uniqueID])
                                           }
                                } else {
                                          postList.append(newPost)
                                      }
                                
                                        PostServices.shared.postList = postList
                                        PostServices.shared.delegate?.postListDidChange()
                                vc.delegate?.postListDidChange()
                                
                               
                            }
                        }
                        let ac = UIAlertController(title: "Notification Scheduled", message: "Remainder created & Added the calendar", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                            self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(ac, animated: true)
                    }
                }
            }
        }
    }
    
    func formattedDate(date: Date) -> String
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM y HH:mm"
            return formatter.string(from: date)
        }
    
  

    
    @objc func setDatePicker(){
        let currentDate = Date() // Get the current date and time
        
        datePickerV.minimumDate = currentDate // Set the minimum date to the current date and time
        datePickerV.datePickerMode = .date
        if #available(iOS 15.0, *) {
            datePickerV.preferredDatePickerStyle = .wheels
        }
        datePickerV.addTarget(self, action: #selector(dateChanged(sender:)), for: .valueChanged)
        self.dateTF.inputView = datePickerV
        
        let toolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelItemPress)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneIemPress))]
        toolbar.sizeToFit()
        dateTF.inputAccessoryView = toolbar
        
    }
    
    @objc func cancelItemPress() {
        dateTF.resignFirstResponder()
        timeTF.resignFirstResponder()
    }
    
    @objc func doneIemPress() {
        dateTF.resignFirstResponder()
        timeTF.resignFirstResponder()
    
    }
 
    
    @objc func dateChanged(sender:UIDatePicker){
        let selectedDate = sender.date
        let currentDate = Date()
        
        if selectedDate < currentDate {
            // Set the selected date to the current date and time
            datePickerV.date = currentDate
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,yyyy"
        self.dateTF.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func setTimePicker(){
        let currentDate = Date() // Get the current date and time
        
        timePickerV.minimumDate = currentDate // Set the minimum date to the current date and time
        timePickerV.datePickerMode = .time
        
        if #available(iOS 15.0, *) {
            timePickerV.preferredDatePickerStyle = .wheels
        }
        
        timePickerV.addTarget(self, action: #selector(timeChanged(sender:)), for: .valueChanged)
        self.timeTF.inputView = timePickerV
        
        let toolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelItemPress)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneIemPress))]
        toolbar.sizeToFit()
        timeTF.inputAccessoryView = toolbar
    }

    @objc func timeChanged(sender:UIDatePicker){
        let selectedDate = sender.date
        let currentDate = Date()
        
        // Check if the selected time is before the current time
        if selectedDate < currentDate {
            // Set the selected date to the current date and time
            timePickerV.date = currentDate
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.timeZone = TimeZone.current
        self.timeTF.text = dateFormatter.string(from: timePickerV.date)
    }

    
    @objc func imgTapped(){
        print("imgTapped")
        let alertVC = UIAlertController(title: "Select Video", message: "", preferredStyle: .actionSheet)
        
        let gallAction = UIAlertAction(title: "Choose from Gallery", style: .default) { _ in
                    let picker = UIImagePickerController()
                    picker.sourceType = .photoLibrary
                    picker.mediaTypes = [UTType.movie.identifier]
                    picker.delegate = self
                    self.present(picker, animated: true)
                }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            
        }
        
        alertVC.addAction(gallAction)
        alertVC.addAction(cancelAction)
        
        present(alertVC, animated: true)
        
    }
}

@available(iOS 15.0, *)
extension AddPostVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
        if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                let asset = AVAsset(url: url)
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                
                let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
                if let imageRef = try? generator.copyCGImage(at: timestamp, actualTime: nil) {
                    let image = UIImage(cgImage: imageRef)
                    // Do something with the preview image
                    // For example, set it to an UIImageView
                    self.selectedImgV.image = image
                }
        }
        
    

        dismiss(animated: true)

    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

