
struct RecordGroupCellVM: Hashable {
  let id: String
  let dateText: String
  let satisfiedCount: Int
  let unsatisfiedCount: Int
  
  var subtitle: String {
    "만족 \(satisfiedCount)개 / 불만족 \(unsatisfiedCount)개"
  }
}

