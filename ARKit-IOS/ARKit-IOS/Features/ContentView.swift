import SwiftUI

struct ContentView: View {
    @State private var showStartText = true
    @State private var hideBreathingText = true
    @State private var showBubbles = false
    @State private var bubblesPopped = 0
    let bubbleTexts = ["Thoughts", "Anxiety", "Stress", "Fear", "Anger"]
    @State private var showBubbleIndices = [Int]()
    
    var body: some View {
        ZStack {
            CustomARViewRepresentable().ignoresSafeArea()

            ForEach(showBubbleIndices, id: \.self) { index in
                BubbleView(text: bubbleTexts[index], show: $showBubbles, popped: $bubblesPopped)
            }

            VStack {
                if showStartText {
                    Text("Let's Start")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(10)
                }
                
                if showBubbles {
                    if bubblesPopped < bubbleTexts.count {
                        Text("Tap the emotion bubble to pop it")
                            .font(.title)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    } else {
                        Text("Well Done!")
                            .font(.title)
                            .bold()
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                }

                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 2)) {
                        self.showBubbles.toggle()
                        self.bubblesPopped = 0
                        self.showBubbleIndices = []
                        if self.showBubbles {
                            self.showBubblesOneByOne()
                        }
                    }
                }) {
                    Text(showBubbles ? "Hide Bubbles" : "Show Bubbles")
                        .font(.title)
                        .bold()
                        .padding()
                        .foregroundColor(.black)
                        .background(Color.blue)
                        .cornerRadius(10)
                }.hidden()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation {
                    self.showStartText = false
                    self.hideBreathingText = false
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                withAnimation(.easeInOut(duration: 2)) {
                    self.showBubbles.toggle()
                    self.bubblesPopped = 0
                    self.showBubbleIndices = []
                    if self.showBubbles {
                        self.showBubblesOneByOne()
                    }
                }
            }        }
        .overlay(alignment: .bottom) {
            ScrollView(.horizontal) {
                HStack {
                    Button {
                        ARManager.shared.actionStream.send(.removeAllAnchors)
                    } label:{
                        Image(systemName: "trash" )
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .padding()
                            .background(.regularMaterial)
                            .cornerRadius(16)
                    }.hidden()
                    Button {
                        ARManager.shared.actionStream.send(.placeSphere(color: Color(.white)))
                    } label:{
                        Color(.white)
                            .frame(width: 40, height: 40)
                            .padding()
                            .background(.regularMaterial)
                            .cornerRadius(16)
                    }.hidden()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            ARManager.shared.actionStream.send(.placeSphere(color: Color(.white)))
                        }
                    }

                }
            }
        }
    }
    
    func showBubblesOneByOne() {
        for i in 0..<bubbleTexts.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                withAnimation {
                    self.showBubbleIndices.append(i)
                }
            }
        }
    }
}


struct BubbleView: View {
    let text: String
    @Binding var show: Bool
    @Binding var popped: Int
    @State private var offset = CGSize.zero
    @State private var isShowing = true
    
    var body: some View {
        if isShowing {
            Text(text)
                .font(.title2)
                .padding(38)
                .background(Color.white.opacity(0.8))
                .clipShape(Circle())
                .shadow(color: .gray, radius: 10, x: 0, y: 10)
                .offset(offset)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 2)) {
                        self.isShowing = false
                        self.popped += 1
                    }
                }
                .onAppear {
                    setInitialPosition()
                    moveBubble()
                }
        }
    }
    
    func setInitialPosition() {
        let xOffset = CGFloat.random(in: -(UIScreen.main.bounds.width/2)...(UIScreen.main.bounds.width/2))
        let yOffset = CGFloat.random(in: -(UIScreen.main.bounds.height/2)...(UIScreen.main.bounds.height/2))
        offset = CGSize(width: xOffset, height: yOffset)
    }
    
    func moveBubble() {
        let xOffset = CGFloat.random(in: -(UIScreen.main.bounds.width*0.75)...(UIScreen.main.bounds.width*0.75))
        let yOffset = CGFloat.random(in: -(UIScreen.main.bounds.height*0.75)...(UIScreen.main.bounds.height*0.75))
        let duration = Double.random(in: 5...7)
        withAnimation(Animation.linear(duration: duration).repeatForever(autoreverses: false)) {
            offset = CGSize(width: xOffset, height: yOffset)
        }
    }
}
#Preview {
    ContentView()
}
