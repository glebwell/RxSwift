//: Please build the scheme 'RxSwiftPlayground' first
import RxSwift

supportCode()

example(of: "ignoreElements") {
  let strikes = PublishSubject<String>()
  let disposeBag = DisposeBag()

  strikes
    .ignoreElements()
    .subscribe { _ in
      print("You're out!")
    }
    .addDisposableTo(disposeBag)

  strikes.onNext("X")
  strikes.onNext("X")
  strikes.onNext("X")
  strikes.onCompleted()
}

example(of: "elementAt") {
  let strikes = PublishSubject<String>()
  let disposeBag = DisposeBag()

  strikes
    .elementAt(2)
    .subscribe(onNext: { _ in
      print("You're out!")
    })
    .addDisposableTo(disposeBag)

  strikes.onNext("X")
  strikes.onNext("X")
  strikes.onNext("X")
  strikes.onCompleted()
}

example(of: "filter") {
  let disposeBag = DisposeBag()

  Observable.of(1, 2, 3, 4, 5, 6)
    .filter { integer in
      integer % 2 == 0
    }
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
}

example(of: "skip") {
  let disposeBag = DisposeBag()

  Observable.of("A", "B", "C", "D", "E", "F")
    .skip(3)
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
}

example(of: "skipWhile") {
  let disposeBag = DisposeBag()

  Observable.of(2, 2, 3, 4, 4)
    .skipWhile { integer in
      integer % 2 == 0
    }
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
}

example(of: "skipUntil") {
  let disposeBag = DisposeBag()

  let subject = PublishSubject<String>()
  let trigger = PublishSubject<String>()

  subject
    .skipUntil(trigger)
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)

  subject.onNext("A")
  subject.onNext("B")

  trigger.onNext("X")
  subject.onNext("C")
}

example(of: "take") {
  let disposeBag = DisposeBag()

  Observable.of(1, 2, 3, 4, 5, 6)
    .take(3)
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
}

example(of: "takeWhileWithIndex") {
  let disposeBag = DisposeBag()

  Observable.of(2, 2, 4, 4, 6, 6)
    .takeWhileWithIndex { integer, index in
      integer % 2 == 0 && index < 3
    }
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
}

example(of: "takeUntil") {
  let disposeBag = DisposeBag()

  let subject = PublishSubject<String>()
  let trigger = PublishSubject<String>()

  subject
    .takeUntil(trigger)
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)

  subject.onNext("A")
  subject.onNext("B")

  trigger.onNext("X")
  subject.onNext("C")
}

example(of: "distinctUntilChanged") {
  let disposeBag = DisposeBag()

  Observable.of("A", "A", "B", "B", "A")
    .distinctUntilChanged()
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
}

example(of: "distinctUntilChanged(_:)") {
  let disposeBag = DisposeBag()

  let formatter = NumberFormatter()
  formatter.numberStyle = .spellOut

  Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
    .distinctUntilChanged { a, b in
      guard let aWords = formatter.string(from: a)?.components(separatedBy: " "),
      let bWords = formatter.string(from: b)?.components(separatedBy: " ")
        else {
          return false
      }
      
      var containsMatch = false
      for aWord in aWords {
        for bWord in bWords {
          if aWord == bWord {
            containsMatch = true
            break
          }
        }
      }

      return containsMatch
    }
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
}

example(of: "challenge 1") {
  let contacts = [
    "603-555-1212": "Florent",
    "212-555-1212": "Junior",
    "408-555-1212": "Marin",
    "617-555-1212": "Scott"
  ]

  let input = PublishSubject<Int>()
  let disposeBag = DisposeBag()

  input
    .skipWhile {
      $0 == 0
    }
    .filter {
      $0 < 10
    }
    .take(10)
    .toArray()
    .debug("id", trimOutput: true)
    .subscribe { event in
      if let digits = event.element {
        let phone = phoneNumber(from: digits)
        if let contact = contacts[phone] {
          print("Dealing \(contact) \(phone)...")
        } else {
          print("Phone number: \(phone). Contact not found")
        }
      }
    }
    .addDisposableTo(disposeBag)

  //  "408-555-1212": "Marin"

  input.onNext(0)
  input.onNext(603)

  input.onNext(2)
  input.onNext(1)

  // Confirm that 7 results in "Contact not found", and then change to 2 and confirm that Junior is found
  input.onNext(2)

  "5551212".characters.forEach {
    if let number = (Int("\($0)")) {
      input.onNext(number)
    }
  }

  input.onNext(9)
}
/*:
 Copyright (c) 2014-2016 Razeware LLC
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */
