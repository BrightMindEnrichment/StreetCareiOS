//
//  ProfileDetails.swift
//  StreetCare
//
//  Created by Michael Thornton on 6/1/23.
//

import SwiftUI
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

struct ProfileDetails: View {
    
    @Environment(\.presentationMode) var presentation
    
    @StateObject var profileDetails = ProfileDetail()

    @State var shouldShowPhotoDialog = false
    @State private var avatarImage: UIImage?
    
    @StateObject var storage = StorageManager(uid: "")
    
    private var adapter = ProfileDetailsAdapter()
    
    var body: some View {

        VStack {

            AvatarView(image: $avatarImage)
            
            Button {
                shouldShowPhotoDialog = true
            } label: {
                Text("Edit Photo").font(.footnote)
            }
            .tint(.blue)

            
            TextFieldView(title: "Display Name", field: $profileDetails.displayName)
            TextFieldView(title: "Organization", field: $profileDetails.organization)
            TextFieldView(title: "Country", field: $profileDetails.country)
            
            NavLinkButton(title: "Save", width: 190.0)
                .padding()
                .onTapGesture {
                    adapter.saveProfile(profileDetails)
                    presentation.wrappedValue.dismiss()
                }
            
            Spacer()
        }
        .onAppear {
            if let user = Auth.auth().currentUser {
                adapter.delegate = self
                adapter.refresh()
                
                storage.uid = user.uid
                let db = Firestore.firestore()
                        db.collection("users").whereField("uid", isEqualTo: user.uid).getDocuments { snapshot, error in
                            if let docs = snapshot?.documents, let doc = docs.first {
                                if let url = doc["photoUrl"] as? String, !url.isEmpty {
                                    if let imageUrl = URL(string: url) {
                                        URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                                            if let data = data, let image = UIImage(data: data) {
                                                DispatchQueue.main.async {
                                                    self.avatarImage = image
                                                }
                                            }
                                        }.resume()
                                    }
                                } else {
                                    storage.getImage()
                                }
        
                            }
                        }
                    }
                }
        .sheet(isPresented: self.$shouldShowPhotoDialog) {
            ImagePickerView(selectedImage: self.$avatarImage, sourceType: .camera)
        }
        .onChange(of: storage.image, perform: { newValue in
            if let img = newValue {
                self.avatarImage = img
            }
        })
        .onChange(of: avatarImage) { newValue in

            if let user = Auth.auth().currentUser {
                print("attempt to save image for \(user.uid)")
                if let img = newValue {
                    storage.upload(image: img)
                }
                else {
                    print("NOT AN IMAGE")
                }
            }
        }

    } // end body
    
    
    
} // end struct



extension ProfileDetails: ProfileDetailsAdapterProtocol {
    func profileDataRefreshed(_ profile: ProfileDetail) {
        self.profileDetails.id = profile.id
        self.profileDetails.displayName = profile.displayName
        self.profileDetails.organization = profile.organization
        self.profileDetails.country = profile.country
        self.profileDetails.documentId = profile.documentId
    }
}



struct TextFieldView: View {

    var title: String
    @Binding var field: String
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                Spacer()
            }
            TextField("optional", text: $field)
                .textFieldStyle(.roundedBorder)
        }.padding()
    }
}


struct ProfileDetails_Previews: PreviewProvider {
    static var previews: some View {
        ProfileDetails()
    }
}
