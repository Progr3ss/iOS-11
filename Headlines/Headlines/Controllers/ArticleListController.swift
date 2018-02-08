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

import UIKit

class ArticleListController: UITableViewController {
  
  var source: Source?
  private let formatter = DateFormatter()
    
    //Remember it's important to retain a reference to the token
  private var token: NSKeyValueObservation?
    
  override func viewDidLoad() {
    super.viewDidLoad()
    formatter.dateFormat = "MMM d, h:mm a"
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    //1 make sure a source has been passed from the sources otherwise exit early
    guard let source = source else {return }
    //2 call observe(_:changeHandleer:) on the service singleton of NewsAPI, this time passing \.aarticles as the keypaht, and store the returned token in token
    token = NewsAPI.service.observe(\.articles){_, _ in
        //3 called on a background queue,
        DispatchQueue.main.async {
            //reload
            self.tableView.reloadData()
        }
    }
    //5  call fetch on NEwsAPI sigleton which will hit he newsAPI and decode the returend JSON
    NewsAPI.service.fetchArticles(for: source)
    
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    //1 it's important to invalidate any observers that are no longer required to avoid them being called unexpectedly
    token?.invalidate()
    //2 reset articles to an empty array
    NewsAPI.service.resetArticles()
    
  }
}

// MARK: UITableViewDataSource

extension ArticleListController {
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return NewsAPI.service.articles.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleCell
    cell.render(article: NewsAPI.service.articles[indexPath.row], using: formatter)
    return cell
  }
}
