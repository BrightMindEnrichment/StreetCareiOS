//
//  AccordianViewController.swift
//  StreetCare
//
//  Created by Michael Thornton on 5/17/22.
//

import UIKit

class AccordianViewController: UIViewController {

    
    var data = [AccordianItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        data.append(AccordianItem(title: "", description: "before_para1", expanded: true, descriptionOnly: true))
        data.append(AccordianItem(title: "before_title2", description: "before_para2"))
        data.append(AccordianItem(title: "before_title3", description: "before_para3"))
        data.append(AccordianItem(title: "before_title4", description: "before_para4"))
        data.append(AccordianItem(title: "before_title5", description: "before_para5"))
    }

} // end class



extension AccordianViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "accordianCell") as? AccordianTableViewCell else {
            preconditionFailure("can't find cell")
        }
        
        let item = data[indexPath.row]
        cell.labelTitle.text = Language.locString(item.title)
        cell.labelDetails.text = Language.locString(item.description)
        
        if item.descriptionOnly {
            cell.imageState.image = nil
        }
        else {
            if item.expanded {
                cell.imageState.image = UIImage(named: "minus")
            }
            else {
                cell.imageState.image = UIImage(named: "plus")
            }
        }
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let item = data[indexPath.row]
        
        let width = tableView.frame.width - (16.0 * 2.0)

        let textTitle = Language.locString(item.title)
        let titleHeight = textTitle.size(font: UIFont.preferredFont(forTextStyle: .headline), width: width)

        let textDescription = Language.locString(item.description)
        let descriptionHeight = textDescription.size(font: UIFont.preferredFont(forTextStyle: .body), width: width)

        if item.expanded {
            return descriptionHeight.height + titleHeight.height + 24.0
        }
        else {
            return titleHeight.height + 14.0
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if data[indexPath.row].descriptionOnly == false {
            data[indexPath.row].expanded = !data[indexPath.row].expanded
            tableView.reloadData()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

} // end extension
