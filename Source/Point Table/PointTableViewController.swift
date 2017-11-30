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
    
    private lazy var dateFormatter: DateFormatter = {
        return DateFormatter()
    }()
    
    private lazy var valueFormatter: NumberFormatter = {
        return NumberFormatter()
    }()
    
    private var points: [Point] = [] {
        didSet {
            tableView?.reloadData()
        }
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems?.insert(editButtonItem, at: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = segue.identifier else { return }
        
        switch segueIdentifier {
        case UI.showPointSegueIdentifier: break
            
        case UI.addPointSegueIdentifier:
            guard let pvc = segue.destination as? PointViewController else { return }
            pvc.delegate = self
            
        case UI.editPointSegueIdentifier: break
            
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
        cell.textLabel?.text = dateFormatter.string(from: point.date)
        cell.detailTextLabel?.text = valueFormatter.string(from: NSNumber(value: point.value))
        
        return cell
    }
}

extension PointTableViewController: PointViewControllerDelegate {
    func pointViewControllerDidRequestSave(_ controller: PointViewController) {
        if let _ = controller.point {
            
        }
        else {
            guard let valueText = controller.valueTextField.text, let value = valueFormatter.number(from: valueText)?.doubleValue else { return }
            let newPoint = Point(date: controller.datePicker.date, value: value)
            graph?.points.append(newPoint)
            delegate?.pointTableViewControllerUpdatedGraph(self)
        }
    }
}
