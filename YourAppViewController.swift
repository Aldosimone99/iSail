import UIKit
import CloudKit

class YourAppViewController: UIViewController {
    // ...existing code...

    let container = CKContainer(identifier: "com.aldosimone.SailSafe")
    let privateDatabase = container.privateCloudDatabase

    func saveDataToiCloud(data: Data, recordName: String) {
        let recordID = CKRecord.ID(recordName: recordName)
        let record = CKRecord(recordType: "YourRecordType", recordID: recordID)
        record["data"] = data as CKRecordValue

        privateDatabase.save(record) { (record, error) in
            if let error = error {
                print("Error saving to iCloud: \(error)")
            } else {
                print("Data successfully saved to iCloud")
            }
        }
    }

    func fetchDataFromiCloud(recordName: String, completion: @escaping (Data?) -> Void) {
        let recordID = CKRecord.ID(recordName: recordName)
        privateDatabase.fetch(withRecordID: recordID) { (record, error) in
            if let error = error {
                print("Error fetching from iCloud: \(error)")
                completion(nil)
            } else if let record = record, let data = record["data"] as? Data {
                completion(data)
            } else {
                completion(nil)
            }
        }
    }

    // ...existing code...
}
