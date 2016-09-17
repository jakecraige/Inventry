import UIKit
import RxSwift

final class InventorySharingViewController: UITableViewController {
  var searchQuery: String? { didSet { tableView.reloadData() } }
  var currentUser: User?
  var partners: [PublicUser] = [] { didSet { tableView.reloadData() } }
  var filteredPartners: [PublicUser]  {
    if let query = searchQuery where !query.isEmpty {
      return partners.filter { $0.name.lowercaseString.containsString(query.lowercaseString) }
    } else {
      return partners
    }
  }
  let searchController = UISearchController(searchResultsController: nil)
  let disposeBag = DisposeBag()

  override func viewDidLoad() {
    definesPresentationContext = true
    searchController.searchResultsUpdater = self
    searchController.searchBar.placeholder = "Search for a user"
    searchController.searchBar.searchBarStyle = .Minimal
    searchController.dimsBackgroundDuringPresentation = false
    tableView.tableHeaderView = searchController.searchBar

    Observable
      .combineLatest(store.user, Database.observeArray() as Observable<[PublicUser]>) { user, users in
        return (user, users)
      }.subscribeNext { [weak self] result in
        self?.currentUser = result.0
        self?.partners = result.1
      }
      .addDisposableTo(disposeBag)
  }
}

extension InventorySharingViewController {
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return filteredPartners.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("InventorySharingCell", forIndexPath: indexPath)
    let user = filteredPartners[indexPath.row]
    cell.textLabel?.text = user.name
    // Switch cell accessory type based on if inventory is shared
//    if currentUser?.inventoryPartners.contains(user.id!) ?? false {
//      cell.accessoryType = UITableViewCellAccessoryType.Checkmark
//    } else {
      cell.accessoryType = .None
//    }
    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let partner = filteredPartners[indexPath.row]
    let action = ToggleInventoryPartner(partner: partner)
    store.dispatch(action).subscribe().addDisposableTo(disposeBag)
  }
}

extension InventorySharingViewController: UISearchResultsUpdating {
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    searchQuery = searchController.searchBar.text
  }
}
