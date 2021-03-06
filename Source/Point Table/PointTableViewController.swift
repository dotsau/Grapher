//
//  PointTableViewController.swift
//  Grapher
//
//  Created by Alexey Donov on 30/11/2017.
//  Copyright © 2017 Alexey Donov. All rights reserved.
//

import UIKit

protocol PointTableViewControllerDelegate: class {
    func pointTableViewControllerUpdatedGraph(_ controller: PointTableViewController)
}

class PointTableViewController: UITableViewController {
    weak var delegate: PointTableViewControllerDelegate?
    
    var graph: Graph? {
        didSet {
            title = graph?.name
            points = graph?.points.sorted { $0.date < $1.date } ?? []
        }
    }
    
    // MARK: Implementation
    
    private struct UI {
        static let pointCellIdentifier = "Point Cell"
        static let showPointSegueIdentifier = "Show Point"
        static let addPointSegueIdentifier = "Add Point"
        static let editPointSegueIdentifier = "Edit Point"
    }
    
    private var points: [Point] = []
    
    @IBAction private func unwind(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems?.insert(editButtonItem, at: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = segue.identifier else { return }
        
        switch segueIdentifier {
        case UI.showPointSegueIdentifier:
            guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else { return }
            guard let pvc = segue.destination.contentViewController as? PointViewController else { return }
            pvc.delegate = self
            pvc.point = points[indexPath.row]
            
        case UI.addPointSegueIdentifier:
            guard let pvc = segue.destination.contentViewController as? PointViewController else { return }
            pvc.delegate = self
            
        default: break
        }
    }
    
    // MARK: UITableViewController
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return points.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let point = points[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UI.pointCellIdentifier, for: indexPath)
        cell.textLabel?.text = Meta.instance.dateFormatter.string(from: point.date)
        cell.detailTextLabel?.text = Meta.instance.valueFormatter.string(from: NSNumber(value: point.value))
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let date = points[indexPath.row].date
            if let index = graph?.points.index(where: { $0.date == date }) {
                UIView.setAnimationsEnabled(false)
                let contentOffset = tableView.contentOffset
                tableView.beginUpdates()
                graph?.points.remove(at: index)
                delegate?.pointTableViewControllerUpdatedGraph(self)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
                tableView.contentOffset = contentOffset
                UIView.setAnimationsEnabled(true)
            }
        }
    }
}

extension PointTableViewController: PointViewControllerDelegate {
    func pointViewControllerDidRequestSave(_ controller: PointViewController) {
        if let _ = controller.point {
            // TODO: Modify point
        }
        else {
            guard let valueText = controller.valueTextField.text, let value = Meta.instance.valueFormatter.number(from: valueText)?.doubleValue else { return }
            let newPoint = Point(date: controller.datePicker.date, value: value)
            graph?.points.append(newPoint)
            tableView.reloadData()
            navigationController?.popViewController(animated: true)
            delegate?.pointTableViewControllerUpdatedGraph(self)
        }
    }
}

