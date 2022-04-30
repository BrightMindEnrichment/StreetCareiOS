//
//  YouTubeViewController.swift
//  StreetCare
//
//  Created by Michael Thornton on 4/29/22.
//

import UIKit

class YouTubeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var playlistId: String?
    
    //safe to force, set in viewDidLoad
    var controller: PlaylistController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let playlistId = playlistId {
            self.controller = PlaylistController(playlistId: playlistId)
        
            controller.delegate = self
        
            controller.refresh()
        }
        else {
            self.controller = PlaylistController(playlistId: "")
        }
    }

    
    func updateUI() {
        tableView.reloadData()
    }
    
} // end class



extension YouTubeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCellView") as? VideoTableViewCell else {
            preconditionFailure("Can't find cell view.  Check storyboard")
        }

        if let videoInfo = controller.videoInformationAtIndex(indexPath.row) {
            //cell.labelTitle.text = videoInfo.title
            //cell.labelDescription.text = videoInfo.description
            cell.imageViewThumbnail.downloaded(from: videoInfo.thumbnailURL)
        }
        
        return cell
    }
    
    

    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{

        
        let label:UILabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text

        label.sizeToFit()
        return label.frame.height
    }
    
    

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCellView") as? VideoTableViewCell else {
//            preconditionFailure("Can't find cell view.  Check storyboard")
//        }
//        
//        if let videoInfo = controller.videoInformationAtIndex(indexPath.row) {
//            
//            let titleHeight = heightForView(text: videoInfo.title, font: cell.labelTitle.font, width: tableView.frame.size.width)
//            let descriptionHeight = heightForView(text: videoInfo.description, font: cell.labelDescription.font, width: tableView.frame.size.width)
//            
//            return (self.view.frame.width * 0.75) + titleHeight + descriptionHeight + 25.0 // 7 spacing on stack, 11 bottom margin
//        }
//        
//        return self.view.frame.width
//    }
} // end extension



extension YouTubeViewController: PlaylistControllerDelegate {
    
    func playlistRefreshed() {
        updateUI()
    }
    
} // end extension
