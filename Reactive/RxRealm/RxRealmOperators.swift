//
//  Operators.swift
//  BaristaFramework
//
//  Created by Santiago Bustamante on 13/10/16.
//  Copyright © 2015 Barista Ventures. All rights reserved.
//

import RxSwift
import RxCocoa
import RxRealm
import RealmSwift
import Realm

infix operator ~> //: AssignmentPrecedence
public func ~> <T>(objects:Results<T> , subscribeNext:@escaping (_ value:Results<T>)->()) -> Disposable{
    return Observable.from(objects).subscribe(onNext:subscribeNext)
}


public func skip<O:ObservableType>(_ count:Int) -> (_ observable:O) -> Observable<O.E> {
    return { (observable:O) in
        return observable.skip(count)
    }
}


//infix operator |> //: AssignmentPrecedence
public func ~> <E, O:ObservableType>(objects:Results<E>, skipA: (Observable<E>) -> O) -> O {
    return skipA(Observable.from(objects))
}




