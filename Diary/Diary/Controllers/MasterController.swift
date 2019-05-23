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
    
    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var dataSource: DataSource = {
        return DataSource(tableView: self.tableView, context: self.managedObjectContext)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        let newButton = UIBarButtonItem(image: UIImage(named: "Icn_write"), style: .done, target: self, action: #selector(MasterController.launchDetailController))
        navigationItem.rightBarButtonItem = newButton
        setupSearchBar()

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
        if segue.identifier == "NewNoteSegue" {
            
            let navigatioController = segue.destination as! UINavigationController
            let addNoteController = navigatioController.topViewController as! DetailController
            
            addNoteController.managedObjectContext = self.managedObjectContext
            addNoteController.update = false
        } else if segue.identifier == "showDetail" {
            let navigatioController = segue.destination as! UINavigationController
            let updateNoteController = navigatioController.topViewController as! DetailController
            updateNoteController.update = true
            if let indexPath = tableView.indexPathForSelectedRow {
                let note = dataSource.object(at: indexPath)
                updateNoteController.note = note
                updateNoteController.managedObjectContext = self.managedObjectContext
            }
        }
            
    }
    
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
            
            quickNote.text = nil
            quickNote.placeholder = "Quick note"
            sender.resignFirstResponder()
        }
    }
}

extension MasterController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchTerm = searchController.searchBar.text else { return }
        
        if !searchTerm.isEmpty {
            dataSource.fetchResultsController = NoteFetchResultsController(fetchRequest: Note.fetchRequestWithText(searchTerm), managedObjectContext: managedObjectContext, tableView: self.tableView)
            self.tableView.reloadData()
            
            
            
//            client.search(withTerm: searchTerm, at: coordinate) { [weak self] result in
//                switch result {
//                case .success(let businesses):
//                    self?.dataSource.update(with: businesses)
//                    self?.tableView.reloadData()
//
//                    self?.mapView.removeAnnotations(self!.mapView.annotations)
//                    self?.mapView.addAnnotations(businesses)
//                case .failure(let error):
//                    print(error)
//                }
//            }
        }
    }
}

