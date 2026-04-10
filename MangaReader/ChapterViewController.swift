import UIKit

class ChapterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let tableView = UITableView()
    
    var mangaID: String = ""
    var mangaTitle: String = ""
    
    var chapters: [[String: Any]] = []
    
    var isLoading = false
    let limit = 100

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = mangaTitle
        
        setupTableView()
        fetchChapters(offset: 0)
        tableView.contentInsetAdjustmentBehavior = .automatic
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Go To Website",
            style: .plain,
            target: self,
            action: #selector(openMangaDex)
        )
    }

    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc func openMangaDex() {
        let urlString = "https://mangadex.org/title/\(mangaID)"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - FIX FOR ORIENTATION

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        })
    }

    // MARK: - Language Mapping

    func getLanguageName(code: String) -> String {
        let map: [String: String] = [
            "en": "English",
            "ja": "Japanese",
            "ko": "Korean",
            "zh": "Chinese",
            "es": "Spanish",
            "fr": "French",
            "de": "German",
            "it": "Italian",
            "pt": "Portuguese",
            "PT": "Portuguese",
            "AB": "Abkhaz",
            "ru": "Russian"
        ]
        
        return map[code] ?? code.uppercased()
    }

    // MARK: - FETCH

    func fetchChapters(offset: Int) {
        
        if isLoading { return }
        isLoading = true
        
        let urlString = "https://api.mangadex.org/chapter?manga=\(mangaID)&limit=\(limit)&offset=\(offset)&order[chapter]=desc"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            
            guard let data = data else { return }
            
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            let rawChapters = json?["data"] as? [[String: Any]] ?? []
            let total = json?["total"] as? Int ?? 0
            
            let newChapters = rawChapters.filter { newItem in
                let newID = newItem["id"] as? String ?? ""
                return !self.chapters.contains {
                    ($0["id"] as? String ?? "") == newID
                }
            }
            
            self.chapters.append(contentsOf: newChapters)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            self.isLoading = false
            
            if self.chapters.count < total {
                self.fetchChapters(offset: offset + self.limit)
            }
            
        }.resume()
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chapters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        let chapter = chapters[indexPath.row]
        
        if let attr = chapter["attributes"] as? [String: Any] {
            
            let chapterNum = attr["chapter"] as? String ?? "Oneshot"
            let langCode = attr["translatedLanguage"] as? String ?? "unknown"
            let language = getLanguageName(code: langCode)
            
            cell.textLabel?.text = "Chapter \(chapterNum) - \(language)"
        }
        
        return cell
    }

    // MARK: - Infinite Scroll

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let position = scrollView.contentOffset.y
        
        if position > (tableView.contentSize.height - scrollView.frame.size.height - 100) {
            if !isLoading {
                fetchChapters(offset: chapters.count)
            }
        }
    }

    // MARK: - Navigation

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let urlString = "https://mangadex.org/title/\(mangaID)"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
