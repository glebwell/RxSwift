//: Please build the scheme 'RxSwiftPlayground' first
import RxSwift

supportCode()

example(of: "startWith") {
  let numbers = Observable.of(2, 3, 4)

  let observable = numbers.startWith(1)
  observable.subscribe(onNext: {
    print($0)
  })
}

example(of: "Observable.concat") {
  let first = Observable.of(1, 2, 3)
  let second = Observable.of(4, 5, 6)

  let observable = Observable.concat([first, second])
  observable.subscribe(onNext: {
    print($0)
  })
}

example(of: "concat") {
  let germanCities = Observable.of("Berlin", "Munich", "Frankfurt")
  let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")

  let observable = germanCities.concat(spanishCities)
  observable.subscribe(onNext: {
    print($0)
  })
}

example(of: "concat one element") {
  let numbers = Observable.of(2, 3, 4)
  let observable = Observable
    .just(1)
    .concat(numbers)
  observable.subscribe(onNext: {
    print($0)
  })
}

example(of: "merge") {
  let left = PublishSubject<String>()
  let right = PublishSubject<String>()

  let source = Observable.of(right.asObservable(), left.asObservable())
  let observable = source.merge()
  let disposable = observable.subscribe(onNext: { value in
    print(value)
  })

  var leftValues = ["Berlin", "Munich", "Frankfurt"]
  var rightValues = ["Madrid", "Barcelona", "Valencia"]

  repeat {
    if arc4random_uniform(2) == 0 {
      if !leftValues.isEmpty {
        left.onNext("Left: " + leftValues.removeFirst())
      } else if !rightValues.isEmpty {
        right.onNext("Right: " + rightValues.removeFirst())
      }
    }
  } while !leftValues.isEmpty || !rightValues.isEmpty

  disposable.dispose()
}

example(of: "combineLatest") {
  let left = PublishSubject<String>()
  let right = PublishSubject<String>()

  let observable = Observable.combineLatest(left, right,
                                            resultSelector: { lastLeft, lastRight in
    "\(lastLeft) \(lastRight)"
  })
  let disposable = observable.subscribe(onNext: {
    print($0)
  })

  print("> Sending a value to Left")
  left.onNext("Hello,")
  print("> Sending a value to Right")
  right.onNext("world")
  print("> Sending another value to Right")
  right.onNext("RxSwift")
  print("> Sending another value to Left")
  left.onNext("Have a good day,")

  disposable.dispose()
}

example(of: "combine user choise and value") {
  let choise: Observable<DateFormatter.Style> =
    Observable.of(.short, .long)

  let dates = Observable.of(Date())

  let observable = Observable.combineLatest(choise, dates) {
    (format, when) -> String in
    let formatter = DateFormatter()
    formatter.dateStyle = format
    return formatter.string(from: when)
  }

  observable.subscribe(onNext: {
    print($0)
  })


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
