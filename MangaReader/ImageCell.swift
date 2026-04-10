import UIKit

class ImageCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    var currentTask: URLSessionDataTask?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.frame = contentView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        currentTask?.cancel()
    }
    
    func loadImage(from urlString: String) {
        
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("https://mangadex.org", forHTTPHeaderField: "Referer")
        
        currentTask = URLSession.shared.dataTask(with: request) { data, _, _ in
            
            if let data = data, let image = UIImage(data: data) {
                
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
        
        currentTask?.resume()
    }
}
