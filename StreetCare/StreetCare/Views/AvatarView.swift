//
//  AvatarView.swift
//  StreetCare
//
//  Created by Michael Thornton on 6/12/23.
//

import SwiftUI


struct AvatarView: View {
    
    @Binding var image: UIImage?
    
    var body: some View {
        if image != nil {
            Image(uiImage: image!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
                .frame(width: 200, height: 200)
        }
        else {
            Image(systemName: "person")
                .font(.largeTitle).padding(EdgeInsets(top: 100.0, leading: 0.0, bottom: 20.0, trailing: 0.0))
        }
    }
}

struct AvatarView_Previews: PreviewProvider {
    
    @State static var img: UIImage?
    
    static var previews: some View {
        AvatarView(image: $img)
    }
}
