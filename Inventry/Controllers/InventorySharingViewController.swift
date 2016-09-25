import UIKit
import RxSwift
import Firebase

final class InventorySharingViewController: UITableViewController {
  var searchQuery: String? { didSet { tableView.reloadData() } }
  var currentUser: PublicUser?
  var partners: [PublicUser] = [] { didSet { tableView.reloadData() } }
  var filteredPartners: [PublicUser]  {
    if let query = searchQuery , !query.isEmpty {
      return partners.filter { $0.name.lowercased().contains(query.lowercased()) }
    } else {
      return partners
    }
  }
  let searchController = UISearchController(searchResultsController: nil)
  let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()

    definesPresentationContext = true
    searchController.searchResultsUpdater = self
    searchController.searchBar.placeholder = "Search for a user"
    searchController.searchBar.searchBarStyle = .minimal
    searchController.dimsBackgroundDuringPresentation = false
    tableView.tableHeaderView = searchController.searchBar
    tableView.tableFooterView = UIView()

    Observable
      .combineLatest(store.user, PublicUsersQuery().build()) { user, users in
        return (user.uid, users)
      }.subscribe(onNext: { [weak self] id, users in
        self?.currentUser = users.find { $0.id! == id }
        self?.partners = users.filter { $0.id! != id }
      })
      .addDisposableTo(disposeBag)
  }
}

extension InventorySharingViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return filteredPartners.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "InventorySharingCell", for: indexPath)
    let user = filteredPartners[(indexPath as NSIndexPath).row]
    cell.textLabel?.text = user.name
    if currentUser?.inventorySharedWith.contains(user.id!) ?? false {
      cell.accessoryType = UITableViewCellAccessoryType.checkmark
    } else {
      cell.accessoryType = .none
    }
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let partner = filteredPartners[(indexPath as NSIndexPath).row]
    let action = ToggleInventoryPartner(user: currentUser!, partner: partner)
    store.dispatch(action).subscribe().addDisposableTo(disposeBag)
  }
}

extension InventorySharingViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    searchQuery = searchController.searchBar.text
  }
}
