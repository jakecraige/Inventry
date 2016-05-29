/** 
 This protocol is used to help Argo know how to decode firebase styles arrays into real ones. 
 If you have a nested array within an object Argo is decoding, you'll need to implement this
 protocol on it.

 It expects the array in Firebase to look like so:

 ```
 {
   "key1": {"the_key_again": "key1", "other_value": 2 },
   "key2": {"the_key_again": "key2", "other_value": 3 }
 }
 ```
 
 The duplicate key is because with the `JSON` type we can't easily create a new one and add it 
 ourselves like we can in the `Database.swift` file where we have a dictionary.
 */
protocol FIRNestedArray { }
