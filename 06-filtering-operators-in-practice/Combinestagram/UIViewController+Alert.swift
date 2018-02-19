//
//  UIViewController+ShowAlert.swift
//  Combinestagram
//
//  Created by Gleb on 18.02.18.
//  Copyright © 2018 Underplot ltd. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

extension UIViewController {
  func alert(title: String, description: String? = nil) -> Observable<Void> {
    return Observable.create { [weak self] observer in
      let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { _ in
        observer.onCompleted()
      }))
      self?.present(alert, animated: true, completion: nil)
      return Disposables.create {
        self?.dismiss(animated: true, completion: nil)
      }
    }
  }
}
