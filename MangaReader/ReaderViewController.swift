import UIKit

class ReaderViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var chapterID: String = ""
    
    var imageUrls: [String] = []
    
    var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupCollectionView()
        fetchPages()
    }

    // MARK: - UI

    func setupCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.backgroundColor = .black
        
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "cell")
        
        view.addSubview(collectionView)
    }

    // MARK: - Fetch Pages

    func fetchPages() {
        
        let urlString = "https://api.mangadex.org/at-home/server/\(chapterID)"
        
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("https://mangadex.org", forHTTPHeaderField: "Referer")
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            
            guard let data = data else { return }
            
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let baseUrl = json?["baseUrl"] as? String,
                  let chapter = json?["chapter"] as? [String: Any],
                  let hash = chapter["hash"] as? String,
                  let dataArray = chapter["data"] as? [String] else { return }
            
            self.imageUrls = dataArray.map {
                "\(baseUrl)/data-saver/\(hash)/\($0)"
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        }.resume()
    }

    // MARK: - CollectionView

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCell
        
        let urlString = imageUrls[indexPath.row]
        cell.loadImage(from: urlString)
        
        return cell
    }

    // MARK: - Dynamic Size

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width
        return CGSize(width: width, height: width * 1.5) // temporary, auto adjusted after load
    }
}
