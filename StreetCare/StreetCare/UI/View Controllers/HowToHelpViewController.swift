//
//  HowToHelpViewController.swift
//  StreetCare
//
//  Created by Michael Thornton on 4/29/22.
//

import UIKit

class HowToHelpViewController: UIViewController {

    @IBOutlet weak var imageRotate: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var timer: Timer?
    var images = [UIImage]()
    var imageIndex = 0
    
    
    var links = [("Start Now", "startNow"), ("What to Give", "soap"), ("How-to Videos", "howToVideos")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    


    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        images.append(UIImage(named: "image12")!)
        images.append(UIImage(named: "image16")!)
        images.append(UIImage(named: "image25")!)
        
        timer = Timer.scheduledTimer(timeInterval: 6.0, target: self, selector: #selector(rotateImage), userInfo: nil, repeats: true)
    }
    
    
    
    @objc func rotateImage() {
        
        imageIndex += 1
        
        if imageIndex >= images.count {
            imageIndex = 0
        }
        
        let toImage = images[imageIndex]
        
        UIView.transition(with: self.imageRotate,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: { self.imageRotate.image = toImage },
                          completion: nil)

    }

} // end class



extension HowToHelpViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Your Toolkit to Help"
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return links.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "howToHelpCell") as? HowToHelpTableViewCell else {
            preconditionFailure("Missing cell - check tag in storyboard")
        }
        
        let linkData = links[indexPath.row]
        cell.textTitle.text = linkData.0
        cell.imageIcon.image = UIImage(named: linkData.1)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            return
        case 1:
            return
        case 2:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "YouTubeViewController") as? YouTubeViewController {
                vc.playlistId = "PLh7GZtyt8qiLKwO_WoE0Vmcu6UMV1AtV9"
                self.navigationController?.pushViewController(vc, animated: true)
            }
        default:
            return
        }

    }
    
} // end extension
