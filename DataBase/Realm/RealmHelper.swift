//
//  Realm.swift
//  BaristaFramework
//
//  Created by Santiago Bustamante on 30/9/15.
//  Copyright © 2015 Barista Ventures. All rights reserved.
//

import Realm
import RealmSwift

public extension Object {
	public func save(){
		do{
			let realm = try Realm()
            do{
                try realm.write({ () -> Void in
                    realm.add(self, update:true)
                })
            }catch _{
                print("REALM: impossible save object")
            }
            
		} catch _{
			print("REALM: impossible get the realm default")
        }
	}
    
    public func update(updateClosure:()->()){
        do{
            let realm = try Realm()
            
            do{
                try realm.write({ () -> Void in
                    updateClosure()
                })
            }catch _{
                print("REALM: impossible update object")
            }
            
        } catch _{
            print("REALM: impossible get the realm default")
        }
    }
    
}

public extension Realm{
    
    public class func update(updateClosure:@escaping (_ realm:Realm)->()){
        do{
            let realm = try Realm()
            do{
                try realm.write({ () -> Void in
                    updateClosure(realm)
                })
            }catch _{
                print("REALM: impossible update object")
            }
            
        } catch _{
            print("REALM: impossible get the realm default")
        }
    }
    
    public class func query(queryClosure:@escaping (_ realm:Realm)->()){
        do{
            let realm = try Realm()
            queryClosure(realm)
            
        } catch _{
            print("REALM: impossible get the realm default")
        }
    }
    
}
