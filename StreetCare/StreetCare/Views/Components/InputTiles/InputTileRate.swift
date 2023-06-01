//
//  InputTileRate.swift
//  StreetCare
//
//  Created by Michael on 4/19/23.
//
import SwiftUI

struct InputTileRate: View {

    var questionNumber: Int
    var totalQuestions: Int
    
    var size = CGSize(width: 300.0, height: 450.0)
    var question: String
        
    @Binding var textValue: String
    @Binding var rating: Int
        
    var nextAction: () -> ()
    var previousAction: () -> ()
    var skipAction: () -> ()
    
    var body: some View {

        ZStack {
            BasicTile(size: CGSize(width: size.width, height: size.height))
            
            VStack {
                
                HStack {
                    
                    Spacer()
                    
                    Button("Skip") {
                        skipAction()
                    }
                    .foregroundColor(.gray)
                    .padding()
                }

                Spacer()

                Text("Question \(questionNumber)/\(totalQuestions)")
                    .foregroundColor(.gray)
                    .font(.footnote)
    
                Text(question)
                    .font(.headline)
                    .padding()
                
                HStack {
                    Image(systemName: starNameForStarNumber(1))
                        .foregroundColor(starColorForStarNumber(1))
                        .onTapGesture {
                            rating = 1
                        }
                    Image(systemName: starNameForStarNumber(2))
                        .foregroundColor(starColorForStarNumber(2))
                        .onTapGesture {
                            rating = 2
                        }
                    Image(systemName: starNameForStarNumber(3))
                        .foregroundColor(starColorForStarNumber(3))
                        .onTapGesture {
                            rating = 3
                        }

                    Image(systemName: starNameForStarNumber(4))
                        .foregroundColor(starColorForStarNumber(4))
                        .onTapGesture {
                            rating = 4
                        }

                    Image(systemName: starNameForStarNumber(5))
                        .foregroundColor(starColorForStarNumber(5))
                        .onTapGesture {
                            rating = 5
                        }

                    //Text("\(rating)")
                }
                .padding()

                VStack {
                    Text("Questions/comments").font(.caption)
                    
                    TextField("optional", text: $textValue)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 200.0)
                    
                    Spacer()
                    
                    ProgressView(value: Double(questionNumber) / Double(totalQuestions))
                        .tint(.yellow)
                        .background(.black)
                        .padding()
                    
                    
                    Spacer()
                }
                HStack {
                    Button("Previous") {
                        previousAction()
                    }
                    .foregroundColor(Color("TextColor"))
                    Spacer()
                    Button("Next") {
                        nextAction()
                    }
                    .foregroundColor(Color("TextColor"))
                }
                .padding()
            }
        }
        .frame(width: size.width, height: size.height)

    } // end body
    
    
    private func starNameForStarNumber(_ starNumber: Int) -> String {
        if starNumber <= rating {
            return "star.fill"
        }
        else {
            return "star"
        }
    }
    
    private func starColorForStarNumber(_ starNumber: Int) -> Color {
        if starNumber <= rating {
            return .yellow
        }
        else {
            return .gray
        }
    }
} // end struct


struct InputTileRate_Previews: PreviewProvider {

    @State static var inputText = ""
    @State static var rating = 3
    
    static var previews: some View {

        InputTileRate(questionNumber: 1, totalQuestions: 1, question: "How am I driving?", textValue: $inputText, rating: $rating) {
            //
        } previousAction: {
            //
        } skipAction: {
            //
        }

    }
}


