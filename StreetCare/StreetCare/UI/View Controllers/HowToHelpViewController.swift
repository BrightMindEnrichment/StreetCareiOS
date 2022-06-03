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
    
    
    var links = [("startNow", "startNow"), ("whatToGive", "soap"), ("howToVideos", "howToVideos")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    


    override func viewWillAppear(_ animated: Bool) {
        
        self.title = Language.locString("howToHelp")
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
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
        return Language.locString("toolkitToHelp")
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return links.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "howToHelpCell") as? HowToHelpTableViewCell else {
            preconditionFailure("Missing cell - check tag in storyboard")
        }
        
        let linkData = links[indexPath.row]
        cell.textTitle.text = Language.locString(linkData.0)
        cell.imageIcon.image = UIImage(named: linkData.1)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "StartNowViewController") as? StartNowViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }

        case 1:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "FeaturedItemViewController") as? FeaturedItemViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case 2:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "PlaylistsViewController") as? PlaylistsViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        default:
            return
        }

    }
    
} // end extension
