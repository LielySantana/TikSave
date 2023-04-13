//
//  ScheduleVC.swift
//  TikSave
//
//  Created by krunal on 20/02/23.
//

import UIKit
import UserNotifications

protocol PostListDelegate {
    func postListDidChange()
    func setup()
}

@available(iOS 15.0, *)
class ScheduleVC: UIViewController, PostListDelegate {
    @IBOutlet weak var tableV: UITableView!
    private var postList = PostServices.shared.postList
    var delegate: PostListDelegate?
    var refreshControl = UIRefreshControl()
    
    func setup() {
        PostServices.shared.delegate = self
        postList = PostServices.shared.postList
        DispatchQueue.main.async {
            self.tableV.dataSource = self
            self.tableV.delegate = self
            self.tableV.reloadData()
        }
//        postListDidChange()
    }

    override func viewDidLoad() {
        setup()
        postListDidChange()
        delegate = self
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? AddPostVC else {return}
        vc.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        delegate?.setup()
        delegate?.postListDidChange()
        
        if !postList.isEmpty {
            if !UserDefaults.standard.bool(forKey: "hasScheduleBefore") {
                // Redirect the user to the ProVC inside the Main storyboard
                let rateVC = self.storyboard?.instantiateViewController(withIdentifier: "RateVC") as! RateVC
                present(rateVC, animated: true)
                UserDefaults.standard.set(true, forKey: "hasScheduleBefore")
            }
        }
    }
    
     func postListDidChange() {
       setup()
    }
}


@available(iOS 15.0, *)
extension ScheduleVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCVC", for: indexPath) as! ScheduleCVC
        cell.postImgV.image = UIImage(data: postList[indexPath.row].picData)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM dd,yyyy, hh:mm a"
        let dateString = dateFormatter.string(from: postList[indexPath.row].date!)
        cell.lbl.text = dateString
        cell.postData = postList[indexPath.row]
        print(postList[indexPath.row].date)
        cell.postImgV.contentMode = .scaleAspectFit
        
//        Separator
        cell.layer.borderWidth = 5
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.masksToBounds = true
        
        let separatorView = UIView()
            separatorView.backgroundColor = .black
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(separatorView)
            separatorView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
            separatorView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
            separatorView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
            separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return cell
    }
    
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! ScheduleCVC
        let postData = currentCell.postData
        print(postData!)
        
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPostVC") as? AddPostVC else {return}
        vc.postData = currentCell.postData
        print(currentCell.postData)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let currentCell = tableView.cellForRow(at: indexPath) as! ScheduleCVC
        let edit = UIContextualAction(style: .normal, title: "Edit"){ _, _, _ in
            
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPostVC") as? AddPostVC else {return}
            vc.postData = currentCell.postData
            print(currentCell.postData)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let delete = UIContextualAction(style: .destructive, title: "Delete"){ _, _, _ in
            let postToDelete = self.postList[indexPath.row]
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [postToDelete.uniqueID])
            self.postList.remove(at: indexPath.row)
            PostServices.shared.postList = self.postList
            self.delegate?.postListDidChange()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [delete, edit])
        return swipeConfiguration
    }
    
   
    
    
}


class ScheduleCVC:UITableViewCell{
    @IBOutlet weak var postImgV: UIImageView!
    @IBOutlet weak var lbl: UILabel!
    var postData: PostModel!
    @IBOutlet weak var calendarImgV: UIImageView!
    
    }




