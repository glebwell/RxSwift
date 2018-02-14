//: Please build the scheme 'RxSwiftPlayground' first
import RxSwift

supportCode()

example(of: "PublishSubject") {
    let subject = PublishSubject<String>()
    subject.onNext("Is anyone listening?")
    let subscriptionOne = subject
        .subscribe(onNext: { string in
            print(string)
        })
    subject.on(.next("1"))
    subject.onNext("2")

    let subscriptionTwo = subject
        .subscribe { event in
            print("2)", event.element ?? event)
        }

    subject.onNext("3")
    subscriptionOne.dispose()
    subject.onNext("4")

    subject.onCompleted()

    subject.onNext("5")

    subscriptionTwo.dispose()

    let disposeBag = DisposeBag()

    subject
        .subscribe {
            print("3)", $0.element ?? $0)
        }
        .addDisposableTo(disposeBag)

    subject.onNext("?")
}

enum MyError: Error {
    case anError
}

func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
    print(label, event.element ?? event.error ?? event)
}

example(of: "BehaviorSubject") {
    let subject = BehaviorSubject(value: "Initial value")
    let disposeBag = DisposeBag()

    subject
        .subscribe {
            print(label: "1)", event: $0)
        }
        .addDisposableTo(disposeBag)

    subject.onNext("X")

    subject.onError(MyError.anError)

    subject
        .subscribe {
            print(label: "2)", event: $0)
        }
        .addDisposableTo(disposeBag)
}

example(of: "ReplaySubject") {
    let subject = ReplaySubject<String>.create(bufferSize: 2)

    let disposeBag = DisposeBag()

    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")

    subject
        .subscribe {
            print(label: "1)", event: $0)
        }
        .addDisposableTo(disposeBag)

    subject
        .subscribe {
            print(label: "2)", event: $0)
        }
        .addDisposableTo(disposeBag)

    subject.onNext("4")
    subject.onError(MyError.anError)
    subject.dispose()

    subject
        .subscribe {
            print(label: "3)", event: $0)
        }
        .addDisposableTo(disposeBag)
}

example(of: "Variable") {
    var variable = Variable("Initial value")
    let disposeBag = DisposeBag()

    variable.value = "New initial value"

    variable.asObservable()
        .subscribe {
            print(label: "1)", event: $0)
        }
        .addDisposableTo(disposeBag)

    variable.value = "1"

    variable.asObservable()
        .subscribe {
            print(label: "2)", event: $0)
        }
        .addDisposableTo(disposeBag)

    variable.value = "2"
}

example(of: "challenge 1") {

    let disposeBag = DisposeBag()

    let dealtHand = PublishSubject<[(String, Int)]>()

    func deal(_ cardCount: UInt) {
        var deck = cards
        var cardsRemaining: UInt32 = 52
        var hand = [(String, Int)]()

        for _ in 0..<cardCount {
            let randomIndex = Int(arc4random_uniform(cardsRemaining))
            hand.append(deck[randomIndex])
            deck.remove(at: randomIndex)
            cardsRemaining -= 1
        }

        // Add code to update dealtHand here

        if points(for: hand) > 21 {
            dealtHand.onError(HandError.busted)
        } else {
            dealtHand.onNext(hand)
        }
    }

    // Add subscription to dealtHand here
    dealtHand
        .subscribe(onNext: {
            print(cardString(for: $0), "score: \(points(for: $0))")
        }, onError: { error in
            print(error)
        }, onCompleted: {
            print("onCompleted")
        }, onDisposed: {
            print("onDisposed")
        })
        .addDisposableTo(disposeBag)

    deal(3)
}

example(of: "challenge 2") {

    enum UserSession {

        case loggedIn, loggedOut
    }

    enum LoginError: Error {

        case invalidCredentials
    }

    let disposeBag = DisposeBag()

    // Create userSession Variable of type UserSession with initial value of .loggedOut
    var userSession = Variable(UserSession.loggedOut)

    // Subscribe to receive next events from userSession
    userSession.asObservable()
        .subscribe { userSession in
            print(userSession)
        }
        .addDisposableTo(disposeBag)

    func logInWith(username: String, password: String, completion: (Error?) -> Void) {
        guard username == "johnny@appleseed.com",
            password == "appleseed"
            else {
                completion(LoginError.invalidCredentials)
                return
        }

        // Update userSession
        userSession.value = UserSession.loggedIn

    }

    func logOut() {
        // Update userSession
        userSession.value = UserSession.loggedOut
    }

    func performActionRequiringLoggedInUser(_ action: () -> Void) {
        // Ensure that userSession is loggedIn and then execute action()
        if userSession.value == .loggedIn {
            action()
        }
    }

    for i in 1...2 {
        let password = i % 2 == 0 ? "appleseed" : "password"

        logInWith(username: "johnny@appleseed.com", password: password) { error in
            guard error == nil else {
                print(error!)
                return
            }

            print("User logged in.")
        }

        performActionRequiringLoggedInUser {
            print("Successfully did something only a logged in user can do.")
        }
    }
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
