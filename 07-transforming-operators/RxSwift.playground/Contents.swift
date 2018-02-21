//: Please build the scheme 'RxSwiftPlayground' first
import RxSwift

supportCode()

example(of: "toArray") {
  let disposeBag = DisposeBag()

  Observable.of("A", "B", "C")
    .toArray()
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
}

example(of: "map") {
  let disposeBag = DisposeBag()

  let formatter = NumberFormatter()
  formatter.numberStyle = .spellOut

  Observable<NSNumber>.of(123, 4, 56)
    .map {
      formatter.string(from: $0) ?? ""
    }
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
}

example(of: "mapWithIndex") {
  let disposeBag = DisposeBag()

  Observable.of(1, 2, 3, 4, 5, 6)
    .mapWithIndex { integer, index in
      index > 2 ? integer * 2 : integer
    }
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
}

struct Student {
  var score: Variable<Int>
}

example(of: "flatMap") {
  let disposeBag = DisposeBag()

  let ryan = Student(score: Variable(80))
  let charlotte = Student(score: Variable(90))

  let student = PublishSubject<Student>()

  student.asObservable()
    .flatMap {
      $0.score.asObservable()
    }
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)

  student.onNext(ryan)
  ryan.score.value = 85

  student.onNext(charlotte)
  ryan.score.value = 95

  charlotte.score.value = 100
}

example(of: "flatMapLatest") {
  let disposeBag = DisposeBag()

  let ryan = Student(score: Variable(80))
  let charlotte = Student(score: Variable(90))

  let student = PublishSubject<Student>()

  student.asObservable()
    .flatMapLatest {
      $0.score.asObservable()
    }
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)

  student.onNext(ryan)
  ryan.score.value = 85

  student.onNext(charlotte)

  ryan.score.value = 95
  charlotte.score.value = 100
}

example(of: "challenge 1") {

  let contacts = [
    "603-555-1212": "Florent",
    "212-555-1212": "Junior",
    "408-555-1212": "Marin",
    "617-555-1212": "Scott"
  ]

  let convert: (String) -> UInt? = { value in
    if let number = UInt(value), number < 10 {
      return number
    }

    let convert: [String: UInt] = [
      "abc": 2, "def": 3, "ghi": 4,
      "jkl": 5, "mno": 6, "pqrs": 7,
      "tuv": 8, "wxyz": 9
      ]

    var converted: UInt? = nil

    convert.keys.forEach {
      if $0.contains(value.lowercased()) {
        converted = convert[$0]
      }
    }
    return converted
  }

  let format: ([UInt]) -> String = {
    var phone = $0.map(String.init).joined()

    phone.insert("-", at: phone.index(
      phone.startIndex,
      offsetBy: 3)
    )

    phone.insert("-", at: phone.index(
      phone.startIndex,
      offsetBy: 7)
    )

    return phone
  }

  let dial: (String) -> String = {
    if let contact = contacts[$0] {
      return "Dialing \(contact) (\($0))..."
    } else {
      return "Contact not found"
    }
  }

  let disposeBag = DisposeBag()

  let subject = Variable<String>("")

  subject.asObservable()
    .debug()
    .map(convert)
    .flatMap {
      return $0 == nil ? Observable.empty() : Observable.just($0!)
    }
    .skipWhile { $0 == 0 }
    .take(10)
    .toArray()
    .map(format)
    .map(dial)
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)

  //"603-555-1212"

  subject.value = "6"
  subject.value = "0"
  subject.value = "3"
  subject.value = "5"
  subject.value = "5"
  subject.value = "5"
  subject.value = "1"
  subject.value = "b"
  subject.value = "1"
  subject.value = "a"
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
