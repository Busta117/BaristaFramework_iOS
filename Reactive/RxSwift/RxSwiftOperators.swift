//
//  Operators.swift
//  BaristaFramework
//
//  Created by Santiago Bustamante on 13/10/16.
//  Copyright © 2015 Barista Ventures. All rights reserved.
//

import RxSwift
import RxCocoa


infix operator <~> : AssignmentPrecedence
public func <~> <E,C: ControlPropertyType>(property: C, variable: Variable<E>) -> Disposable where C.E == E? {
    
    let bindToUIDisposable = variable.asObservable()
        .bindTo(property)
    let bindToVariable = property
        .subscribe(onNext: { n in
            if let n = n{
                variable.value = n
            }
            }, onCompleted:  {
                bindToUIDisposable.dispose()
        })
    
    return Disposables.create([bindToUIDisposable, bindToVariable])
}

/*
public func <~> <E,C: ControlPropertyType>(variable: Variable<E>, property: C) -> Disposable where C.E == E? {
    return property <~> variable
}*/


/*
 operator ~>
 */

infix operator ~> : AssignmentPrecedence
public func ~> <E, V: Variable<E>, O: ObserverType where O.E == E?>(variable: V, property: O) -> Disposable{
    let bindDisposable = variable.asObservable()
        .map { $0 }
        .bindTo(property)
    return bindDisposable
}

public func ~> <E, V: Variable<E>, O: ObserverType where O.E == E>(variable: V, property: O) -> Disposable{
    let bindDisposable = variable.asObservable()
        .bindTo(property)
    return bindDisposable
}





/*
public func ~> <E,O: ObserverType>(property: O, variable: Variable<E?>) -> Disposable where O.E == E?{
    return (variable ~> property)
}

public func ~> <E,O: ObserverType>(property: O, variable: Variable<E>) -> Disposable where O.E == E{
    return (variable ~> property)
}*/

public func ~> <E>(variable: Variable<E?>, subscribeNext:@escaping (_ value:E?)->()) -> Disposable{
    let bindDisposable = variable.asObservable()
        .map { $0 }
        .bindNext(subscribeNext)
    return bindDisposable
}

public func ~> <E> (variable:Variable<E>, subscribeNext:@escaping (_ value:E?)->()) -> Disposable{
    let bindDisposable = variable.asObservable()
        .bindNext(subscribeNext)
    return bindDisposable
}

public func ~> <E,O: ObservableType> (observable:O, subscribeNext:@escaping (_ value:E?)->()) -> Disposable where O.E == E?{
    return observable.subscribe(onNext: subscribeNext)
}

public func ~> <E,O: ObservableType> (observable:O, subscribeNext:@escaping (_ value:E)->()) -> Disposable where O.E == E{
    return observable.subscribe(onNext: subscribeNext)
}


public func ~> <C:ControlPropertyType,O: ObservableType> (observable:O, property:C) -> Disposable where C.E == O.E{
    return observable.bindTo(property)
}
/*
public func ~> <C:ControlPropertyType,O: ObservableType> (property:C, observable:O) -> Disposable where C.E == O.E{
    return observable ~> property
}*/

public func ~> (addDisposable: Disposable, ToBag: DisposeBag)  {
    addDisposable.addDisposableTo(ToBag)
}



/*
 operator ~>
 */
infix operator <~ : AssignmentPrecedence
public func <~ <E,O: ObserverType>(variable: Variable<E?>, property: O) -> Disposable where O.E == E?{
    return (variable ~> property)
}

public func <~ <E,O: ObserverType>(variable: Variable<E>, property: O) -> Disposable where O.E == E{
    return (variable ~> property)
}

/*public func <~ <E,O: ObserverType>(property: O, variable: Variable<E?>) -> Disposable where O.E == E?{
    return (variable ~> property)
}

public func <~ <E,O: ObserverType>(property: O, variable: Variable<E>) -> Disposable where O.E == E{
    return (variable ~> property)
}*/

public func <~ <C:ControlPropertyType,O: ObservableType> (observable:O, property:C) -> Disposable where C.E == O.E{
    return observable ~> property
}

/*
public func <~ <C:ControlPropertyType,O: ObservableType> (property:C, observable:O) -> Disposable where C.E == O.E{
    return observable ~> property
}*/




