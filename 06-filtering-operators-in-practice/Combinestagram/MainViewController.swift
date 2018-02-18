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

class MainViewController: UIViewController {

  @IBOutlet weak var imagePreview: UIImageView!
  @IBOutlet weak var buttonClear: UIButton!
  @IBOutlet weak var buttonSave: UIButton!
  @IBOutlet weak var itemAdd: UIBarButtonItem!

  private let bag = DisposeBag()
  private let images = Variable<[UIImage]>([])

  override func viewDidLoad() {
    super.viewDidLoad()
    images.asObservable()
        .subscribe(onNext: { [weak self] photos in
            self?.updateUI(photos: photos)
        })
        .addDisposableTo(bag)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    print("resources \(RxSwift.Resources.total)")
  }

  private func updateUI(photos: [UIImage]) {
    let photosCount = photos.count
    buttonSave.isEnabled = photosCount > 0 && photosCount % 2 == 0
    buttonClear.isEnabled = photosCount > 0
    itemAdd.isEnabled = photosCount < 6
    title = photosCount > 0 ? "\(photosCount) photos" : "Collage"
    guard let preview = imagePreview else { return }
    preview.image = UIImage.collage(images: photos, size: preview.frame.size)
  }

  @IBAction func actionClear() {
    images.value = []
  }

  @IBAction func actionSave() {
    guard let image = imagePreview.image else { return }

    PhotoWriter.save(image)
      .subscribe(onError: { [weak self] error in
        self?.showMessage("Error", description: error.localizedDescription)
      }, onCompleted: { [weak self] in
        self?.showMessage("Saved")
        self?.actionClear()
      })
      .addDisposableTo(bag)
  }

  @IBAction func actionAdd() {
    //images.value.append(UIImage(named: "IMG_1907.jpg")!)
    let photosViewController = storyboard!.instantiateViewController(
        withIdentifier: "PhotosViewController") as! PhotosViewController

    let newPhotos = photosViewController.selectedPhotos.share()

    newPhotos
      .filter { newImage in
        return newImage.size.width > newImage.size.height
      }
      .subscribe(onNext: { [weak self] newImage in
        guard let images = self?.images else { return }
        images.value.append(newImage)
      }, onDisposed: {
            print("completed photo selection")
      })
      .addDisposableTo(photosViewController.bag)

    newPhotos
      .ignoreElements()
      .subscribe(onCompleted: { [weak self] in
        self?.updateNavigationIcon()
      })
      .addDisposableTo(photosViewController.bag)

    navigationController!.pushViewController(photosViewController, animated: true)
  }

  func showMessage(_ title: String, description: String? = nil) {
    alert(title, description: description)
      .subscribe(onCompleted: { [weak self] in
        self?.dismiss(animated: true, completion: nil)
      })
      .addDisposableTo(bag)
  }

  private func updateNavigationIcon() {
    let icon = imagePreview.image?
      .scaled(CGSize(width: 22, height: 22))
      .withRenderingMode(.alwaysOriginal)

    navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon, style: .done,
                                                       target: nil, action: nil)
  }
}
