//
//  ToolsSearchResultController.swift
//  Tools
//
//  Created by Mac on 2021/4/13.
//

import UIKit
import VoceChat

protocol ContactsSearchResultViewControllerDelegate {
    func searchResult(searchResult: ContactsSearchResultViewController, didSelectUser: VCUserModel)
}

class ContactsSearchResultViewController: BaseViewController {
    
    var dataArray = [VCUserModel]()
    var resultArray = [VCUserModel]()
    var nav : UINavigationController?
    
    var delegate: ContactsSearchResultViewControllerDelegate?
    
    lazy var tableView : UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ContactListCell", bundle: Bundle.main), forCellReuseIdentifier: NSStringFromClass(ContactListCell.classForCoder()))
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ContactsSearchResultViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        resultArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ContactListCell.classForCoder()), for: indexPath) as! ContactListCell
        if indexPath.row < resultArray.count {
            cell.model = resultArray[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        
        delegate?.searchResult(searchResult: self, didSelectUser: resultArray[indexPath.row])
    }
}

extension ContactsSearchResultViewController : UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        let inputStr = searchController.searchBar.text
        resultArray.removeAll()
        for subModel in dataArray {
            if subModel.name.contains(inputStr ?? "") {
                resultArray.append(subModel)
            }
        }
        tableView.reloadData()
    }
}

extension ContactsSearchResultViewController : UISearchBarDelegate{
    
}
