import Foundation

extension AsyncSequence {
    func eraseToAsyncThrowingStream() -> AsyncThrowingStream<Element, Error> {
        var iterator = makeAsyncIterator()
        return AsyncThrowingStream(unfolding: { try await iterator.next() })
    }
}
