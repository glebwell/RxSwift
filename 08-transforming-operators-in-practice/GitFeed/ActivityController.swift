/*
 * Copyright (c) 2016 Razeware LLC
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
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

func cachedFileURL(_ filename: String) -> URL {
  return FileManager.default
    .urls(for: .cachesDirectory, in: .allDomainsMask)
    .first!
    .appendingPathComponent(filename)
}

class ActivityController: UITableViewController {

  let repo = "ReactiveX/RxSwift"

  fileprivate let events = Variable<[Event]>([])
  fileprivate let bag = DisposeBag()
  private let eventsFileURL = cachedFileURL("events.plist")
  private let modifiedFileURL = cachedFileURL("modified.txt")
  fileprivate let lastModified = Variable<NSString?>(nil)

  override func viewDidLoad() {
    super.viewDidLoad()
    title = repo

    self.refreshControl = UIRefreshControl()
    let refreshControl = self.refreshControl!

    refreshControl.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
    refreshControl.tintColor = UIColor.darkGray
    refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)

    let eventsArray = (NSArray(contentsOf: eventsFileURL)) as? [[String: Any]] ?? []
    events.value = eventsArray.flatMap(Event.init)

    lastModified.value = try? NSString(contentsOf: modifiedFileURL, usedEncoding: nil)
    refresh()
  }

  func refresh() {
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.fetchEvents(repo: strongSelf.repo)
    }
  }

  func fetchEvents(repo: String) {
    let response = Observable.from(["https://api.github.com/search/repositories?q=language:swift&per_page=5"])
      .map { urlString -> URLRequest in
        return URLRequest(url: URL(string: urlString)!)
      }
      .flatMap { request -> Observable<Any> in
        return URLSession.shared.rx.json(request: request)
      }
      .flatMap { json -> Observable<String> in
        guard let dict = json as? AnyDict, let items = dict["items"] as? [AnyDict]
          else { return Observable.never() }

        let repoNames = items.flatMap {
          return $0["full_name"] as? String
        }

        return Observable.from(repoNames)
      }
      .map { urlString -> URL in
        return URL(string: "https://api.github.com/repos/\(urlString)/events?per_page=5")!
      }
      .map { [weak self] url -> URLRequest in
        var request = URLRequest(url: url)
        if let modifiedHeader = self?.lastModified.value {
          request.addValue(modifiedHeader as String, forHTTPHeaderField: "Last-Modified")
        }
        return request
      }
      .flatMap { request -> Observable<(HTTPURLResponse, Data)> in
        return URLSession.shared.rx.response(request: request)
      }
      .shareReplay(1)

    response
      .filter { response, _ in
        return 200..<300 ~= response.statusCode
      }
      .map { _, data -> [[String: Any]] in
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
          let result = jsonObject as? [[String: Any]] else {
            return []
        }
        return result
      }
      .filter { objects in
        return !objects.isEmpty
      }
      .map { objects in
        return objects.flatMap(Event.init)
      }
      .subscribe(onNext: { [weak self] newEvents in
        self?.processEvents(newEvents)
      })
      .addDisposableTo(bag)


    response
      .filter { response, _ in
        return 200..<400 ~= response.statusCode
      }
      .flatMap { response, _ -> Observable<NSString> in
        guard let value = response.allHeaderFields["Last-Modified"] as?
          NSString else {
            return Observable.never()
        }
        return Observable.just(value)
      }
      .subscribe(onNext: { [weak self] modifiedHeader in
        guard let strongSelf = self else { return }
        strongSelf.lastModified.value = modifiedHeader
        try? modifiedHeader.write(to: strongSelf.modifiedFileURL, atomically: true,
                                  encoding: String.Encoding.utf8.rawValue)
      })
      .addDisposableTo(bag)

    response
      .filter { response, _ in
        return response.statusCode >= 400
      }
      .subscribe { [weak self] _ in
        self?.updateUI()
      }
      .addDisposableTo(bag)
  }

  func processEvents(_ newEvents: [Event]) {
    var updatedEvents = newEvents + events.value
    if updatedEvents.count > 50 {
      updatedEvents = Array<Event>(updatedEvents.prefix(upTo: 50))
    }

    events.value = updatedEvents

    updateUI()

    let eventsArray = updatedEvents.map { $0.dictionary } as NSArray
    eventsArray.write(to: eventsFileURL, atomically: true)
  }

  private func updateUI() {
    DispatchQueue.main.async { [weak self] in
      self?.tableView.reloadData()
      self?.refreshControl?.endRefreshing()
    }
  }

  // MARK: - Table Data Source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return events.value.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let event = events.value[indexPath.row]

    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
    cell.textLabel?.text = event.name
    cell.detailTextLabel?.text = event.repo + ", " + event.action.replacingOccurrences(of: "Event", with: "").lowercased()
    cell.imageView?.kf.setImage(with: event.imageUrl, placeholder: UIImage(named: "blank-avatar"))
    return cell
  }
}
