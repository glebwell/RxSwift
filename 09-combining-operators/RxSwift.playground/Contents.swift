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

example(of: "zip") {
  enum Weather {
    case cloudy
    case sunny
  }

  let left: Observable<Weather> = Observable.of(.sunny, .cloudy, .cloudy, .sunny)
  let right = Observable.of("Lisbon", "Copenhagen", "London", "Madrid", "Vienna")

  let observable = Observable.zip(left, right) { weather, city in
    return "It's \(weather) in \(city)"
  }
  observable.subscribe(onNext: { value in
    print(value)
  })
}

example(of: "withLatestFrom") {
  let button = PublishSubject<Void>()
  let textField = PublishSubject<String>()

  //let observable = button.withLatestFrom(textField)
  let observable = textField.sample(button)
  let disposable = observable.subscribe(onNext: {
    print($0)
  })

  textField.onNext("Par")
  textField.onNext("Pari")
  textField.onNext("Paris")

  button.onNext(Void())
  button.onNext(Void())

  disposable.dispose()
}

example(of: "amb") {
  let left = PublishSubject<String>()
  let right = PublishSubject<String>()

  let observable = left.amb(right)
  let disposable = observable.subscribe(onNext: {
    print($0)
  })

  left.onNext("Lisbon")
  right.onNext("Copenhagen")
  left.onNext("London")
  left.onNext("Madrid")
  right.onNext("Vienna")

  disposable.dispose()
}

example(of: "switchLatest") {
  let one = PublishSubject<String>()
  let two = PublishSubject<String>()
  let three = PublishSubject<String>()

  let source = PublishSubject<Observable<String>>()

  let observable = source.switchLatest()

  let disposable = observable.subscribe(onNext: {
    print($0)
  })

  source.onNext(one)
  one.onNext("Some text from sequence one")
  two.onNext("Some text from sequence two")

  source.onNext(two)
  two.onNext("More text from sequence two")

  one.onNext("and also from sequence one")

  source.onNext(three)
  two.onNext("Why don't you seem me?")
  one.onNext("I'm alone, help me")
  three.onNext("Hey it's three. I win.")

  source.onNext(one)
  one.onNext("Nope. It's me, one!")

  disposable.dispose()
}

example(of: "reduce") {
  let source = Observable.of(1, 3, 5, 7, 9)

  let observable = source.reduce(0, accumulator: +)
  observable.subscribe(onNext: {
    print($0)
  }).dispose()
}

example(of: "scan") {
  let source = Observable.of(1, 3, 5, 7, 9)

  let observable = source.scan(0, accumulator: +)
  observable.subscribe(onNext: {
    print($0)
  }).dispose()
}

example(of: "challenge 1, first variant") {
  let disposeBag = DisposeBag()

  let source = Observable.of(1, 3, 5, 7, 9)

  let sum = source.scan(0, accumulator: +)
  let observable = Observable.zip(source, sum)

  observable
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
}

example(of: "challenge 1, second variant") {
  let disposeBag = DisposeBag()

  let source = Observable.of(1, 3, 5, 7, 9)

  let observable = source.scan((0,0), accumulator: { tuple, current in
    return (current, tuple.1 + current)
  })

  observable
    .subscribe(onNext: {
      print($0)
    })
    .addDisposableTo(disposeBag)
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
