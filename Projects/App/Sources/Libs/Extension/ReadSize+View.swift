import Foundation
import SwiftUI

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear.preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self) { newSize in
            onChange(newSize)
        }
    }
}

struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {
    func readFrame(
        in space: some CoordinateSpaceProtocol = .local,
        onChange: @escaping (CGRect) -> Void) -> some View
    {
        background(
            GeometryReader { geometryProxy in
                Color.clear.preference(key: FramePreferenceKey.self, value: geometryProxy.frame(in: space))
            }
        )
        .onPreferenceChange(FramePreferenceKey.self) { newFrame in
            onChange(newFrame)
            print("[readFrame] \(newFrame)")
        }
    }
}

struct FramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}
