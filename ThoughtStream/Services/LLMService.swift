import Foundation

/// A lightweight client-side mock for the LLM command execution API.
/// It simulates streaming chunks without performing any network requests.
final class LLMService {
    struct Config {
        let baseURL: URL
        let apiKey: String

        static let `default`: Config = {
            // Prefer reading from Info.plist if present
            if let info = Bundle.main.infoDictionary,
               let base = info["LLM_BASE_URL"] as? String,
               let key = info["LLM_API_KEY"] as? String,
               let url = URL(string: base) {
                return Config(baseURL: url, apiKey: key)
            }
            // Fallback to hardcoded dev values (for local dev only)
            return Config(
                baseURL: URL(string: "http://thoughstream-api-t2zqdu-33e0ee-72-11-148-114.traefik.me")!,
                apiKey: "9c86da8e-c86e-4a26-b007-a6c8afc5d922"
            )
        }()
    }

    private let config: Config

    init(config: Config = .default) {
        self.config = config
    }
    enum LLMServiceError: LocalizedError {
        case missingText
        case unsupportedCommand(String)
        case invalidResponse
        case network(String)

        var errorDescription: String? {
            switch self {
            case .missingText:
                return "需要提供文本内容才能执行此命令。"
            case .unsupportedCommand(let cmd):
                return "不支持的命令：\(cmd)"
            case .invalidResponse:
                return "服务器返回了无效的数据。"
            case .network(let msg):
                return msg
            }
        }
    }
    /// Execute a registered command against the current session context.
    /// This mock ignores any remote networking and yields canned chunks.
    ///
    /// - Parameters:
    ///   - sessionId: Logical session identifier for conversation scoping.
    ///   - command: Command name, e.g. "idiomatic_english".
    ///   - input: Structured payload for the command. Optional in this mock.
    ///   - stream: When true (default), yields chunks with small delays.
    struct CommandResult {
        let stream: AsyncThrowingStream<String, Error>
        let analysis: AnalysisData?
    }

    func executeCommand(
        sessionId: String,
        command: String,
        input: [String: Any],
        stream: Bool = true
    ) async throws -> CommandResult {
        switch command {
        case "idiomatic_english":
            guard let messages = input["messages"] as? [Message], !messages.isEmpty else {
                throw LLMServiceError.missingText
            }
            // Build payload and call remote analyze API
            let window = Self.sliceWindowForIdiomatic(messages: messages)
            let userOnly = window.filter { $0.sendByYou && !$0.isCommand }
            let payload = Self.composeAnalyzePayload(from: userOnly)
            let analysis = try await analyze(messagesPayload: payload)

            // Compose a detailed output including original, suggestions and fixed sentences
            let combined = Self.composeDetailedOutput(from: analysis)
            let chunks = Self.splitForStreaming(combined)

            let streamObj: AsyncThrowingStream<String, Error>
            if stream {
                streamObj = AsyncThrowingStream { continuation in
                    Task {
                        for (idx, part) in chunks.enumerated() {
                            try? await Task.sleep(nanoseconds: UInt64(200_000_000 + idx * 80_000_000))
                            continuation.yield(part)
                        }
                        continuation.finish()
                    }
                }
            } else {
                let final = chunks.joined()
                streamObj = AsyncThrowingStream { continuation in
                    continuation.yield(final)
                    continuation.finish()
                }
            }
            return CommandResult(stream: streamObj, analysis: analysis)
        default:
            throw LLMServiceError.unsupportedCommand(command)
        }
    }

    // MARK: - Helpers
    private static func sliceWindowForIdiomatic(messages: [Message]) -> ArraySlice<Message> {
        // Only include user messages since the previous `idiomatic_english` command
        let idiomaticKey = "idiomatic_english"
        let cmdIndices = messages.enumerated().compactMap { idx, m in
            (m.isCommand && m.command?.key == idiomaticKey) ? idx : nil
        }
        let currentCmdIndex = cmdIndices.last
        let previousCmdIndex = cmdIndices.dropLast().last
        let start = (previousCmdIndex ?? -1) + 1
        let end = currentCmdIndex ?? messages.count
        let safeStart = max(0, start)
        let safeEnd = max(safeStart, min(end, messages.count))
        return messages[safeStart..<safeEnd]
    }

    private static func composeDetailedOutput(from analysis: AnalysisData) -> String {
        guard !analysis.revisions.isEmpty else {
            return "Here’s a more idiomatic version:\n\n" + (analysis.revisions.last?.good_to_say ?? "")
        }

        var lines: [String] = []
        lines.append("以下是建议的修改和说明：\n")
        for rev in analysis.revisions {
            lines.append("原句：\(rev.original)")
            lines.append("修改：\(rev.good_to_say)")
            if !rev.suggestions.isEmpty {
                lines.append("建议：")
                for (idx, s) in rev.suggestions.enumerated() {
                    lines.append("\(idx + 1). \(s)")
                }
            }
            lines.append("")
        }
        return lines.joined(separator: "\n")
    }

    private static func composeAnalyzePayload(from userMessages: [Message]) -> String {
        let lines = userMessages.compactMap { m -> String? in
            let t = m.text.trimmingCharacters(in: .whitespacesAndNewlines)
            return t.isEmpty ? nil : "You: \(t)"
        }
        return lines.joined(separator: "\n")
    }

    private static func splitForStreaming(_ combined: String) -> [String] {
        let mid = combined.index(combined.startIndex, offsetBy: min(24, combined.count))
        let end1 = combined.index(combined.startIndex, offsetBy: min(64, combined.count))
        return [
            String(combined[..<mid]),
            String(combined[mid..<(combined.count > 64 ? end1 : combined.endIndex)]),
            combined.count > 64 ? String(combined[end1...]) : ""
        ].filter { !$0.isEmpty }
    }

    // MARK: - Networking
    private func analyze(messagesPayload: String) async throws -> AnalysisData {
        var req = URLRequest(url: config.baseURL.appendingPathComponent("/api/llm/analyze"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(config.apiKey, forHTTPHeaderField: "x-api-key")
        let body: [String: String] = ["messages": messagesPayload]
        req.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
                throw LLMServiceError.network("网络请求失败，状态码：\(code)")
            }
            let decoded = try JSONDecoder().decode(AnalysisAPIResponse.self, from: data)
            guard decoded.code == 0, let d = decoded.data else { throw LLMServiceError.invalidResponse }
            return d
        } catch let e as LLMServiceError {
            throw e
        } catch {
            throw LLMServiceError.network(error.localizedDescription)
        }
    }
}

// MARK: - API Models
struct AnalysisAPIResponse: Decodable {
    let code: Int
    let data: AnalysisData?
}

struct AnalysisData: Decodable, Encodable {
    struct Revision: Decodable, Encodable {
        let index: Int
        let original: String
        let good_to_say: String
        let main_issue: String
        let suggestions: [String]
        let explanations: [String]
    }
    let revisions: [Revision]
    let suggest_topic: String?
    let tags: [String]?
    let reviews: [String]?
}
