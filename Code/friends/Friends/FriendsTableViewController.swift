//
//  FriendsTableViewController.swift
//  Friends
//
//  Created by Jussi Suojanen on 07/11/16.
//  Copyright © 2016 Jimmy. All rights reserved.
//

import UIKit
import PKHUD

public class FriendsTableViewController: UITableViewController {

    let viewModel: FriendsTableViewViewModel = FriendsTableViewViewModel()

    public override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        viewModel.getFriends()
    }

    func bindViewModel() {
        viewModel.friendCells.bindAndFire() { [weak self] _ in
            self?.tableView?.reloadData()
        }

        viewModel.onShowError = { [weak self] alert in
            self?.presentSingleButtonDialog(alert: alert)
        }


        viewModel.showLoadingHud.bind() { [weak self] visible in
            if let `self` = self {
                PKHUD.sharedHUD.contentView = PKHUDSystemActivityIndicatorView()
                visible ? PKHUD.sharedHUD.show(onView: self.view) : PKHUD.sharedHUD.hide()
            }
        }
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "friendsToAddFriend",
            let destinationViewController = segue.destination as? FriendViewController {
            destinationViewController.viewModel = AddFriendViewModel()
            destinationViewController.updateFriends = { [weak self] in
                self?.viewModel.getFriends()
            }
        }

        if segue.identifier == "friendToUpdateFriend",
            let destinationViewController = segue.destination as? FriendViewController,
            let indexPath = tableView.indexPathForSelectedRow {

            switch viewModel.friendCells.value[indexPath.row] {
            case .normal(let viewModel):
                destinationViewController.viewModel = UpdateFriendViewModel(friend:viewModel.friendItem)
                destinationViewController.updateFriends = { [weak self] in
                    self?.viewModel.getFriends()
                }
            case .empty, .error:
                // nop
                break
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension FriendsTableViewController {

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.friendCells.value.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch viewModel.friendCells.value[indexPath.row] {
        case .normal(let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as? FriendTableViewCell else {
                return UITableViewCell()
            }

            cell.viewModel = viewModel
            return cell
        case .error(let message):
            let cell = UITableViewCell()
            cell.isUserInteractionEnabled = false
            cell.textLabel?.text = message
            return cell
        case .empty:
            let cell = UITableViewCell()
            cell.isUserInteractionEnabled = false
            cell.textLabel?.text = "No data available"
            return cell
        }
    }

    public override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    public override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteFriend(at: indexPath.row)
        }
    }
}

extension FriendsTableViewController: SingleButtonDialogPresenter { }
