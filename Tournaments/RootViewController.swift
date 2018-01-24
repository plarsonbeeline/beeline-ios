//
//  RootViewController.swift
//  Tournaments
//
//  Created by Phil Larson on 1/23/18.
//  Copyright © 2017 Phil Larson. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class RootViewController: UITableViewController {

    // MARK: - Initialize
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("Tournaments", comment: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions

    func show(_ error: Error?) {
        guard let error = error else { return }
        let alertController = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    func loadData() {
        API.shared.loadTournaments { tournaments, error in
            guard let tournaments = tournaments else {
                self.show(error)
                return
            }

            self.tournaments = tournaments
            self.tableView.reloadData()
        }
    }

    func addParticipation(to tournament: Tournament, with completionHandler: ((Participation?, Swift.Error?)->Void)? = nil) {
        API.shared.addParticipation(to: tournament.identifier) { participation, error in
            if let participation = participation {
                tournament.participation = participation
            }

            completionHandler?(participation, error)
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tournaments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tournament = self.tournaments[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tournament", for: indexPath)
        cell.textLabel?.text = tournament.name
        cell.detailTextLabel?.text = DateFormatter.localizedString(from: tournament.date, dateStyle: .short, timeStyle: .short)
        cell.accessoryType = tournament.participation != nil ? .checkmark : .none
        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark

        let tournament = self.tournaments[indexPath.row]
        self.addParticipation(to: tournament) { participation, error in
            if let participation = participation {
                let alertController = UIAlertController(title: NSLocalizedString("Entered", comment: ""), message: participation.entryMessage, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
                self.show(error)
            }
        }
    }

    // MARK: - UIViewController
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tableView = self.tableView
        tableView?.allowsMultipleSelection = true
        tableView?.register(TournamentTableViewCell.self, forCellReuseIdentifier: "Tournament")
    }

    // MARK: - Accessing

    var tournaments: [Tournament] = []

}
