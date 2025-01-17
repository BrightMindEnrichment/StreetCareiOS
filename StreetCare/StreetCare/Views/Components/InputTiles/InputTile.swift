////
////  InputTile.swift
////  StreetCare
////
////  Created by Michael on 4/10/23.
////
//
//import SwiftUI
//
//enum InputTileDataType {
//    case text
//    case datetime
//}
//
//
//struct InputTile: View {
//
//    var questionNumber = 1
//    var totalQuestions = 1
//    
//    var size = CGSize(width: 300.0, height: 400.0)
//    var question = "An error has occ"
//    
//    var inputType = InputTileDataType.text
//    
//    @Binding var textValue: String
//    @Binding var datetimeValue: Date
//        
//    var nextAction: () -> ()
//    var skipAction: () -> ()
//    
//    var body: some View {
//
//        ZStack {
//            BasicTile(size: CGSize(width: size.width, height: size.height))
//            
//            VStack {
//                Spacer()
//                Text("Question \(questionNumber)/\(totalQuestions)")
//                    .foregroundColor(.gray)
//                    .padding()
//    
//                Text(question)
//                    .padding()
//                
//                switch inputType {
//                case .text:
//                    TextField("optional", text: $textValue)
//                        .textFieldStyle(.roundedBorder)
//                        .frame(width: 200.0)
//                case .datetime:
//                    DatePicker("", selection: $datetimeValue)
//                        .padding()
//                }
//                
//                Spacer()
//                
//                HStack {
//                    Button("Previous") {
//                        skipAction()
//                    }
//                    Spacer()
//                    Button("Next") {
//                        nextAction()
//                    }
//                }
//                .padding()
//            }
//        }
//        .frame(width: size.width, height: size.height)
//
//    } // end body
//} // end struct
//
//
////struct InputTile_Previews: PreviewProvider {
////
////    @State static var inputText = ""
////
////    static var previews: some View {
////        InputTile(textValue: $inputText) {
////            // next action
////        } skipAction: {
////            // skip action
////        }
////
////    }
////}
