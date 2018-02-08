/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation

class NewsAPI : NSObject{
  
  static let service = NewsAPI()
  
    private struct Response: Codable {
    
        let sources: [Source]?
        let articles: [Article]?
    }
    
  private enum API {
    private static let basePath = "https://newsapi.org/v1"
    /*
     Head on over to https://newsapi.org/register to get your
     free API key, and then replace the value below with it.
     */
    private static let key = "2a5c58729f7747acb16bd859502b1c61"
    
    case sources
    case articles(Source)
    
    func fetch(completion: @escaping (Data) -> ()) {
      let session = URLSession(configuration: .default)
      let task = session.dataTask(with: path()) { (data, response, error) in
        guard let data = data, error == nil else { return }
        completion(data)
      }
      task.resume()
    }
    
    private func path() -> URL {
      switch self {
      case .sources:
        return URL(string: "\(API.basePath)/sources")!
      case .articles(let source):
        return URL(string: "\(API.basePath)/articles?source=\(source.id)&apiKey=\(API.key)")!
      }
    }
  }
    //KVO-complaint is to mark any observable properties as requiring dynamic dispath
    //Dynamic modifier to inform the compiler that no optimizations should take place
    //@objc dynamic private(set) var sources: [Source] = []
    @objc dynamic private(set) var sources: [Source] = []
    @objc dynamic private(set) var articles: [Article] = []

  
  func fetchSources() {
    API.sources.fetch { data in
      if let json = String(data: data, encoding: .utf8) {
        print(json)
      }
        
        //Create a JSONDecoder and ask it to decode the data from the API response into an instance of Response.
        if let sources = try! JSONDecoder().decode(
            Response.self, from: data).sources {
            self.sources = sources
        }
        
    }
  }
  
  func fetchArticles(for source: Source) {
    let formatter = ISO8601DateFormatter()
    let customDateHandler: (Decoder) throws -> Date = { decoder in
        //1 encoding and decoding is recursive,
        var string = try decoder.singleValueContainer().decode(String.self)
        //2 deleteMillisecondsIfPresent an extenstion of string  looks at teh length of the string an if it equals 24, it removes charcacters 20-23
        string.deleteMillisecondsIfPresent()
        guard let date = formatter.date(from: string) else { return Date() }
        //return the decoding process
        return date
    }
    
    API.articles(source).fetch { data in
        //create an instance of JSONDecoder
        let decoder = JSONDecoder()
        //set date to decoding stragey to interpret dates using the ISO 8601 stardard
//        decoder.dateDecodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .custom(customDateHandler)
        //attempt to unwrap the articles optional
        if let articles = try! decoder.decode(Response.self, from: data).articles{
            self.articles = articles
        }
        
    }
  }
  
  func resetArticles() {
    articles = []
  }
}
