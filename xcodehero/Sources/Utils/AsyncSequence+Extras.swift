import Foundation

extension AsyncSequence {
    func eraseToAsyncThrowingStream() -> AsyncThrowingStream<Element, Error> {
        var iterator = self.makeAsyncIterator()
        return AsyncThrowingStream(unfolding: { try await iterator.next() })
    }
}
