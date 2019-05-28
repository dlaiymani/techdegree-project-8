//
//  MasterController.swift
//  Diary
//
//  Created by davidlaiymani on 21/05/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import UIKit
import CoreData

class MasterController: UITableViewController {
    
    let managedObjectContext = CoreDataStack().managedObjectContext
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var quickNote: UITextField!
    @IBOutlet weak var iconQuickNote: UIImageView!
    
    var topViewHeight = 0
    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var dataSource: DataSource = {
        return DataSource(tableView: self.tableView, context: self.managedObjectContext)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
        // Left and right bar button
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        let newButton = UIBarButtonItem(image: UIImage(named: "Icn_write"), style: .done, target: self, action: #selector(MasterController.launchDetailController))
        navigationItem.rightBarButtonItem = newButton
        // Search controller
        setupSearchBar()
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = .black
        let appearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        appearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        // Quick note icon
        iconQuickNote.layer.cornerRadius = iconQuickNote.frame.height/2
        iconQuickNote.clipsToBounds = true
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    @objc func launchDetailController() {
        performSegue(withIdentifier: "NewNoteSegue", sender: self)
    
    }
    
    func setupSearchBar() {
        self.navigationItem.titleView = searchController.searchBar
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewNoteSegue" { // New note button tapped
            
            let navigatioController = segue.destination as! UINavigationController
            let addNoteController = navigatioController.topViewController as! DetailController
            
            addNoteController.managedObjectContext = self.managedObjectContext
            addNoteController.update = false
        } else if segue.identifier == "showDetail" { // A cell (a note) has been tapped
            let navigatioController = segue.destination as! UINavigationController
            let updateNoteController = navigatioController.topViewController as! DetailController
            updateNoteController.update = true
            if let indexPath = tableView.indexPathForSelectedRow { // The tapped cell
                let note = dataSource.object(at: indexPath)
                updateNoteController.note = note
                updateNoteController.managedObjectContext = self.managedObjectContext
            }
        }
    }
    
    
    // Quick note. When the user hits return, a new note is created with only a text and a creation date
    @IBAction func returnTapped(_ sender: UITextField) {
        guard let text = quickNote.text, !text.isEmpty else {
            return
        }
        
        let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: managedObjectContext) as! Note
        
        if let text = quickNote.text {
            note.text = text
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
            note.text = text
            note.modificationDate = dateFormatter.string(from: Date())
            note.longitude = 0.0
            note.latitude = 0.0
            note.locationDescription = "📍 No location"
            note.smiley = "none"
            note.photos = nil
            managedObjectContext.saveChanges()
            
            // Reset the quick note
            quickNote.text = nil
            quickNote.placeholder = "Quick note"
            sender.resignFirstResponder()
        }
    }
}

// MARK: SearchController management

extension MasterController: UISearchResultsUpdating, UITextFieldDelegate {
    // When the search controller is activated i.e. the user enters a text,
    // we change the fetchResultController to retreive the corresponding notes
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchTerm = searchController.searchBar.text else { return }
        
        if !searchTerm.isEmpty {
            dataSource.fetchResultsController = NoteFetchResultsController(fetchRequest: Note.fetchRequestWithText(searchTerm), managedObjectContext: managedObjectContext, tableView: self.tableView)
            self.tableView.reloadData()
        }
    }
    
}


// SearchBar delegate
extension MasterController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dataSource.fetchResultsController = NoteFetchResultsController(fetchRequest: Note.fetchRequest(), managedObjectContext: managedObjectContext, tableView: self.tableView)
        // The quick note view is displayed
        topView.frame.size.height = CGFloat(topViewHeight)
        topView.isHidden = false
        self.tableView.reloadData()
    }
    
    // When the user enter some text, the quick note view is dismissed
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        topViewHeight = Int(topView.frame.size.height)
        topView.frame.size.height=0
        topView.isHidden = true
        tableView.reloadData()
    }
    
    // Cross button tapped
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            dataSource.fetchResultsController = NoteFetchResultsController(fetchRequest: Note.fetchRequest(), managedObjectContext: managedObjectContext, tableView: self.tableView)
            topView.frame.size.height = CGFloat(topViewHeight)
            topView.isHidden = false
            self.tableView.reloadData()
        }
    }
}
