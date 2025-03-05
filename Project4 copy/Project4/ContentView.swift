import SwiftUI

struct ContentView: View {
    @State private var flippedIndexes: Set<Int> = []  // Track which card is flipped
    @State private var data: [Color] = []  // Array to hold the card color data
    @State private var showSheet = false  // To control the visibility of the action sheet
    @State private var selectedPairs = 10  // Default to 10 pairs
    @State private var matchedPairs: Set<Int> = []  // Track matched pairs

    let maxPairs = 10
    let colorPalette: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink, .gray, .brown, .cyan]  // Color options for pairs

    var body: some View {
        VStack {
            Spacer()  // Add Spacer to move the title lower

            // Title at the top
            Text("Card Matching Game")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            HStack {
                Button(action: {
                    showSheet.toggle()  // Show action sheet when button is clicked
                }) {
                    Text("Choose Pairs")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .actionSheet(isPresented: $showSheet) {
                    ActionSheet(
                        title: Text("Select Number of Pairs"),
                        buttons: [
                            .default(Text("3 Pairs")) { setPairs(3) },
                            .default(Text("6 Pairs")) { setPairs(6) },
                            .default(Text("10 Pairs")) { setPairs(10) },
                            .cancel()
                        ]
                    )
                }
                
                Spacer()

                // Reset button
                Button(action: {
                    resetGame()  // Reset the game when button is clicked
                }) {
                    Text("Reset")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }

            // The main game display
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                    ForEach(data.indices, id: \.self) { index in
                        if !matchedPairs.contains(index) { // Only display non-matched cards
                            ZStack {
                                // Front side of the card (colored rectangle)
                                Rectangle()
                                    .fill(flippedIndexes.contains(index) ? data[index] : Color.blue)
                                    .frame(height: 150)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                    .onTapGesture {
                                        withAnimation {
                                            if flippedIndexes.contains(index) {
                                                flippedIndexes.remove(index)  // Flip back
                                            } else if flippedIndexes.count < 2 {  // Allow only two cards to be flipped
                                                flippedIndexes.insert(index)  // Flip over
                                                
                                                // Check if two cards are flipped
                                                if flippedIndexes.count == 2 {
                                                    // Get the flipped indexes
                                                    let flippedArray = Array(flippedIndexes)
                                                    let firstCardIndex = flippedArray[0]
                                                    let secondCardIndex = flippedArray[1]
                                                    
                                                    // Check if the colors match
                                                    if data[firstCardIndex] == data[secondCardIndex] {
                                                        // If the cards match, add them to the matched set
                                                        matchedPairs.insert(firstCardIndex)
                                                        matchedPairs.insert(secondCardIndex)
                                                    }
                                                    
                                                    // Flip the cards back after a small delay if they don't match
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                        withAnimation {
                                                            flippedIndexes.remove(firstCardIndex)
                                                            flippedIndexes.remove(secondCardIndex)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .rotation3DEffect(
                                        flippedIndexes.contains(index) ? .degrees(180) : .degrees(0),
                                        axis: (x: 0, y: 1, z: 0),
                                        anchor: .center,
                                        perspective: 0.5
                                    )
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
            }
            .edgesIgnoringSafeArea(.all)
        }
        .onAppear {
            setPairs(selectedPairs)  // Set the initial number of pairs
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .top, endPoint: .bottom))  // Set the gradient background
        .edgesIgnoringSafeArea(.all)  // Ensure the background extends to the edges of the screen
    }

    // Function to set the number of pairs
    func setPairs(_ count: Int) {
        selectedPairs = count
        
        // Use the first `count` colors from the palette to create pairs
        let pairs = Array(colorPalette.prefix(count))
        
        // Create an array with pairs of each color
        data = pairs.flatMap { [ $0, $0 ] }
        
        // Shuffle the array to randomize card positions
        data.shuffle()
        
        flippedIndexes = [] // Reset flipped cards
        matchedPairs = [] // Reset matched pairs
    }

    // Function to reset the game
    func resetGame() {
        setPairs(selectedPairs)  // Reset pairs
        flippedIndexes = []  // Reset flipped cards
        matchedPairs = []  // Reset matched pairs
    }
}

#Preview {
    ContentView()
}
