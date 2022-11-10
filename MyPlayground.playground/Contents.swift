// Example for Paul Lee
// 2022.01.29
// Animation using Value.
import SwiftUI
import PlaygroundSupport
struct AnimationTest: View {
    // Think of animationAmount as a light switch
    // The view has one look when value is 1.0 and a different look when value is 1.5
    @State private var animationAmount = 1.0
    var body: some View {
        Button("Tap Me") {
            // important button function here
        }
        .padding(50)
        .background(.yellow)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(.indigo)
                .scaleEffect(animationAmount)
                .opacity(1.5 - animationAmount)
            // value tells SwiftUI to render scale and opacity between 1.0 and 1.5
            // SwiftUI determines how many frames to render based on duration
                .animation(
                    .easeInOut(duration: 1)
                        .repeatForever(autoreverses: false),
                    value: animationAmount
                )
        )
        .onAppear {
            // Switch the value to 1.5
            // The view has a different look when the value is 1.5
            animationAmount = 1.5
        }
    }
}

PlaygroundPage.current.setLiveView(AnimationTest().frame(width: 300, height: 300))
