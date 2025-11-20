import SwiftUI

struct LargeNavBarView: View {
    var body: some View {
        HStack(spacing: 15) {
            CircleView(size: 60, iconSize: 24)
            VStack(alignment: .leading, spacing: 4) {
                Text("Good morning,")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Alex!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            Spacer()
            Image(systemName: "gearshape")
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.1))
                .clipShape(Circle())
        }
        .padding(.horizontal)
    }
}

struct CircleView: View {
    let size: CGFloat
    let iconSize: CGFloat
    let accentOrange = Color.orange
    
    var body: some View {
        ZStack {
            Circle().fill(accentOrange)
            Image(systemName: "person.fill")
                .foregroundColor(.white)
                .font(.system(size: iconSize, weight: .bold))
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ZStack {
        ThoughtStreamAsset.Colors.bgPrimary.swiftUIColor.ignoresSafeArea()
        VStack {
            LargeNavBarView()
        }
    }
}
