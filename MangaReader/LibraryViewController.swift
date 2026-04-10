import UIKit

class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    let tableView = UITableView()
    let searchBar = UISearchBar()
    
    var mangaTitles: [String] = []
    var mangaIDs: [String] = []
    
    var offset = 0
    let limit = 20
    var isLoading = false
    
    var isSearching = false
    var currentQuery = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupSearchBar()
        setupTableView()
        fetchManga()
    }

    // MARK: - Setup UI

    func setupSearchBar() {
        
        searchBar.delegate = self
        searchBar.placeholder = "Search Manga..."
        searchBar.showsCancelButton = true
        
        searchBar.searchTextField.isUserInteractionEnabled = true
        searchBar.searchTextField.clearButtonMode = .whileEditing
    }

    func setupTableView() {
        
        let topContainer = UIView()
        topContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 110)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 10, width: view.frame.width, height: 30))
        titleLabel.text = "Manga Library"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        
        searchBar.frame = CGRect(x: 0, y: 55, width: view.frame.width, height: 50)
        
        topContainer.addSubview(titleLabel)
        topContainer.addSubview(searchBar)
        
        view.addSubview(topContainer)
        
        tableView.frame = CGRect(x: 0,
                                 y: topContainer.frame.maxY,
                                 width: view.frame.width,
                                 height: view.frame.height - topContainer.frame.maxY)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
    }

    // MARK: - API Calls

    func fetchManga() {
        
        if isLoading { return }
        isLoading = true
        
        MangaService.shared.fetchManga(limit: limit, offset: offset) { [weak self] data in
            
            guard let self = self else { return }
            self.handleResponse(data: data)
        }
    }

    func searchManga() {
        
        if isLoading { return }
        isLoading = true
        
        MangaService.shared.searchManga(query: currentQuery, limit: limit, offset: offset) { [weak self] data in
            
            guard let self = self else { return }
            self.handleResponse(data: data)
        }
    }

    func handleResponse(data: [[String: Any]]) {
        
        for item in data {
            
            let id = item["id"] as? String ?? ""
            
            if let attributes = item["attributes"] as? [String: Any],
               let titleDict = attributes["title"] as? [String: String] {
                
                let title = titleDict["en"] ?? titleDict.values.first ?? "No Title"
                
                self.mangaTitles.append(title)
                self.mangaIDs.append(id)
            }
        }
        
        self.offset += self.limit
        self.isLoading = false
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - SearchBar

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.text, !text.isEmpty else { return }
        
        isSearching = true
        currentQuery = text
        
        offset = 0
        mangaTitles.removeAll()
        mangaIDs.removeAll()
        
        searchManga()
        searchBar.resignFirstResponder()
    }

    // 🔥 UPDATED: Cancel button acts as BACK
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        isSearching = false
        currentQuery = ""
        
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        offset = 0
        mangaTitles.removeAll()
        mangaIDs.removeAll()
        
        fetchManga()
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mangaTitles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = mangaTitles[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let chapterVC = ChapterViewController()
        chapterVC.mangaID = mangaIDs[indexPath.row]
        chapterVC.mangaTitle = mangaTitles[indexPath.row]
        
        navigationController?.pushViewController(chapterVC, animated: true)
    }

    // MARK: - Infinite Scroll

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let position = scrollView.contentOffset.y
        
        if position > (tableView.contentSize.height - scrollView.frame.size.height - 100) {
            
            if isSearching {
                searchManga()
            } else {
                fetchManga()
            }
        }
    }
}
