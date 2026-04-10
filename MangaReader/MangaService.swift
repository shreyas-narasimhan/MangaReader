import Foundation

class MangaService {
    
    static let shared = MangaService()
    
    // Normal fetch
    func fetchManga(limit: Int, offset: Int, completion: @escaping ([[String: Any]]) -> Void) {
        
        let urlString = "https://api.mangadex.org/manga?limit=\(limit)&offset=\(offset)"
        
        print("📡 Fetching Manga List API:")
        print(urlString)
        
        makeRequest(urlString: urlString, completion: completion)
    }
    
    // Search fetch
    func searchManga(query: String, limit: Int, offset: Int, completion: @escaping ([[String: Any]]) -> Void) {
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let urlString = "https://api.mangadex.org/manga?title=\(encodedQuery)&limit=\(limit)&offset=\(offset)"
        
        print("🔍 Searching Manga API:")
        print(urlString)
        
        makeRequest(urlString: urlString, completion: completion)
    }
    
    // Common request handler
    private func makeRequest(urlString: String, completion: @escaping ([[String: Any]]) -> Void) {
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                print("❌ API Error:", error)
                completion([])
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ Status Code:", httpResponse.statusCode)
            }
            
            guard let data = data else {
                print("❌ No Data Received")
                completion([])
                return
            }
            
            // 🔥 Raw JSON log (optional but useful)
            if let rawString = String(data: data, encoding: .utf8) {
                print("📦 Raw JSON Response:")
                print(rawString.prefix(500)) // limit output
            }
            
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            let mangaArray = json?["data"] as? [[String: Any]] ?? []
            
            print("📚 Manga Count:", mangaArray.count)
            
            // 🔥 Print manga titles
            for item in mangaArray.prefix(5) {
                if let attr = item["attributes"] as? [String: Any],
                   let titleDict = attr["title"] as? [String: String],
                   let title = titleDict["en"] ?? titleDict.values.first {
                    
                    print("📖 Manga:", title)
                }
            }
            
            completion(mangaArray)
            
        }.resume()
    }
}
