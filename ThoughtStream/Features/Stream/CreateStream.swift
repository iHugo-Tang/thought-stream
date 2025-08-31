import SwiftUI
import LucideIcons

struct CreateStream: View {
    @Environment(\.tabBarHeight) private var tabBarHeight
    @Environment(\.dismiss) private var dismiss

    @State private var thoughtText: String = ""
    @State private var cancelButtonWidth: CGFloat = 0
    @State private var isEditorExpanded: Bool = false
    @Namespace private var editorNamespace

    var body: some View {
        ZStack {
            if isEditorExpanded {
                expandedEditorCard
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        promptCard
                        editorCard
                        
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, tabBarHeight + 8)
                }
            }
        }
        .background(isEditorExpanded ? Color.thoughtStream.white : Color.thoughtStream.neutral.gray50)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.thoughtStream.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar { navigationBar }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isEditorExpanded)
    }
}

// MARK: - Navigation Bar
private extension CreateStream {
    @ToolbarContentBuilder
    var navigationBar: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(spacing: 8) {
                Image(uiImage: Lucide.pen)
                    .renderingMode(.template)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.thoughtStream.neutral.gray800)
                Text("Write")
                    .appFont(size: .lg, weight: .bold)
                    .foregroundColor(.thoughtStream.neutral.gray800)
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Text("Free")
                .appFont(size: .xs, weight: .medium)
                .appCapsuleTag(
                    background: .thoughtStream.theme.green100,
                    foreground: .thoughtStream.theme.green700,
                    horizontal: 8,
                    vertical: 4
                )
        }
    }
}

// MARK: - Subviews
private extension CreateStream {
    var promptCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text("What is one thing you're looking\nforward to this week?")
                    .appFont(size: .sm, weight: .medium)
                    .foregroundColor(.thoughtStream.neutral.gray700)
                Spacer()
                Button(action: {}) {
                    Image(uiImage: Lucide.x)
                        .renderingMode(.template)
                        .foregroundColor(.thoughtStream.neutral.gray400)
                }
                .frame(width: 20, height: 20)
            }

            HStack(alignment: .center, spacing: 8) {
                (Text("Try using:")
                    + Text("looking forward to, can't wait to, on the horizon")
                ).appFont(size: .sm, weight: .medium)
                .foregroundColor(.thoughtStream.neutral.gray600)
            }
            .padding(12)
            .background(Color.thoughtStream.theme.green50)
            .cornerRadius(8)
        }
        .padding(16)
        .appCard(cornerRadius: 12)
    }

    var editorCard: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading) {
                textEditor
            }
            .padding(16)

            Divider()

            HStack(spacing: 12) {
                CircleIconButton(image: Lucide.mic)
                CircleIconButton(image: Lucide.slidersHorizontal)
                Spacer()
                actionBar
            }
            .padding(12)
        }
        .background(Color.thoughtStream.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
        .matchedGeometryEffect(id: "editorContainer", in: editorNamespace)
    }

    var expandedEditorCard: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading) {
                textEditor
            }
            .padding(16)

            Spacer(minLength: 0)

            Divider()

            HStack(spacing: 12) {
                CircleIconButton(image: Lucide.mic)
                CircleIconButton(image: Lucide.slidersHorizontal)
                Spacer()
                actionBar
            }
            .padding(12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.thoughtStream.white)
        .cornerRadius(0)
        .shadow(color: Color.clear, radius: 0, x: 0, y: 0)
        .matchedGeometryEffect(id: "editorContainer", in: editorNamespace)
    }

    var textEditor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $thoughtText)
                .frame(minHeight: isEditorExpanded ? 360 : 180)
                .appFont(size: .base)
                .foregroundColor(.thoughtStream.neutral.gray800)

            if thoughtText.isEmpty {
                Text("Start writing your thoughts in English...")
                    .appFont(size: .base)
                    .foregroundColor(.thoughtStream.neutral.gray300)
                    .padding(.top, 8)
                    .padding(.leading, 5)
                    .allowsHitTesting(false)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button(action: { isEditorExpanded.toggle() }) {
                Image(systemName: isEditorExpanded ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                    .renderingMode(.template)
                    .foregroundColor(.thoughtStream.neutral.gray700)
                    .frame(width: 20, height: 20)
                    .padding(8)
                    .background(Color.thoughtStream.neutral.gray200)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
    }

    var actionBar: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Text("Cancel")
                    .appFont(size: .sm)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Color.clear)
                    .foregroundColor(.thoughtStream.neutral.gray600)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.thoughtStream.neutral.gray300, lineWidth: 1)
                    )
                    .cornerRadius(8)
                    .overlay(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear { cancelButtonWidth = proxy.size.width }
                                .onChange(of: proxy.size.width) { newWidth in
                                    cancelButtonWidth = newWidth
                                }
                        }
                    )
            }

            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(uiImage: Lucide.send)
                        .renderingMode(.template)
                        .foregroundColor(.thoughtStream.white)
                        .frame(width: 16, height: 16)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .frame(width: cancelButtonWidth == 0 ? nil : cancelButtonWidth)
                .background(Color.thoughtStream.theme.green600)
                .foregroundColor(.thoughtStream.white)
                .cornerRadius(8)
            }
        }
        .padding(.top, 4)
    }
}

// MARK: - Components
private struct CircleIconButton: View {
    let image: UIImage

    var body: some View {
        Button(action: {}) {
            Image(uiImage: image)
                .renderingMode(.template)
                .foregroundColor(.thoughtStream.neutral.gray700)
                .frame(width: 20, height: 20)
                .padding(8)
                .background(Color.thoughtStream.neutral.gray200)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

struct CreateStream_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { CreateStream() }
    }
}


