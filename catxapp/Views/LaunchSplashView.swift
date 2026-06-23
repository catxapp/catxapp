import SwiftUI

struct LaunchSplashView: View {
    var body: some View {
        ZStack {
            Color("LaunchBackground")
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image("LaunchLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))

                Text("Catalytic converter pricing")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(spacing: 10) {
                    ProgressView()
                        .controlSize(.regular)

                    Text("Loading catalog…")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    LaunchSplashView()
        .preferredColorScheme(.dark)
}
