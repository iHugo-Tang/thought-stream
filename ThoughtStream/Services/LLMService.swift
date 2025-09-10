import Foundation

/// A lightweight client-side mock for the LLM command execution API.
/// It simulates streaming chunks without performing any network requests.
final class LLMService {
    /// Execute a registered command against the current session context.
    /// This mock ignores any remote networking and yields canned chunks.
    ///
    /// - Parameters:
    ///   - sessionId: Logical session identifier for conversation scoping.
    ///   - command: Command name, e.g. "idiomatic_english".
    ///   - input: Structured payload for the command. Optional in this mock.
    ///   - stream: When true (default), yields chunks with small delays.
    func executeCommand(
        sessionId: String,
        command: String,
        input: [String: Any],
        stream: Bool = true
    ) async throws -> AsyncThrowingStream<String, Error> {
        // Choose a mock script based on the command and input
        let chunks: [String]
        switch command {
        case "idiomatic_english", "地道英语":
            if let text = input["text"] as? String, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                // Pretend we rewrote the user's text
                chunks = Self.idiomaticRewrite(for: text)
            } else {
                // Command-only mode (no text yet) – acknowledge and give guidance
                chunks = [
                    "地道英语模式已开启。",
                    "发送你的文本，我会优化为更自然、地道的英文。",
                ]
            }
        default:
            chunks = [
                "命令已接收：\(command)。",
                "这是本地模拟的流式响应，无网络请求。",
            ]
        }

        if stream {
            return AsyncThrowingStream { continuation in
                Task {
                    for (idx, part) in chunks.enumerated() {
                        // Small increasing delay to mimic token streaming
                        try? await Task.sleep(nanoseconds: UInt64(200_000_000 + idx * 80_000_000))
                        continuation.yield(part)
                    }
                    continuation.finish()
                }
            }
        } else {
            // Non-streaming: return a single concatenated message
            let final = chunks.joined()
            return AsyncThrowingStream { continuation in
                continuation.yield(final)
                continuation.finish()
            }
        }
    }

    private static func idiomaticRewrite(for text: String) -> [String] {
        // Extremely naive rewrite just for demo; split into 2–4 chunks
        // In a real implementation, this would be produced by the backend.
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let sample = "Here’s a more idiomatic version: \n\n"
        let improved: String
        if trimmed.lowercased().hasPrefix("i write to you") {
            improved = "I’m writing to ask for your help regarding…"
        } else if trimmed.lowercased().hasPrefix("please help") {
            improved = "Could you please help me with…"
        } else {
            improved = "\(trimmed)" // pass-through for now
        }
        let combined = sample + improved
        // Split into rough chunks to mimic streaming
        let mid = combined.index(combined.startIndex, offsetBy: min(24, combined.count))
        let end = combined.index(combined.startIndex, offsetBy: min(64, combined.count))
        return [
            String(combined[..<mid]),
            String(combined[mid..<(combined.count > 64 ? end : combined.endIndex)]),
            combined.count > 64 ? String(combined[end...]) : ""
        ].filter { !$0.isEmpty }
    }
}

