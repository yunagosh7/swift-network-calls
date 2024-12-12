//
//  ContentView.swift
//  network-calls
//
//  Created by Juan Cruz Vila on 12/12/2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var userName: String = ""
    
    @State private var user: GithubUser?
    
    var body: some View {
        VStack {
    
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundColor(.gray)
            }
            .frame(width: 120, height: 120)
            .padding(.top, 50)
           
            Text(user?.login ?? "Username")
                .bold()
                .font(.title)
            Text(user?.bio ?? "User bio.")
                .padding()
            Spacer()
            
            TextField("Enter the username of the user", text: $userName)
                           .padding()
                           .background(Color.white)
                           .cornerRadius(10)
                           .shadow(radius: 5)
                           .padding(.horizontal, 40) // Agregar algo de padding en los lados
                           .textFieldStyle(RoundedBorderTextFieldStyle()) // Usar estilo redondeado de borde

            Button(action: {
                         Task {
                             do {
                                 user = try await getUser(userName) // Buscar usuario por el nombre ingresado
                             } catch GHError.invalidURL {
                                 print("Invalid URL")
                             } catch GHError.invalidData {
                                 print("Invalid Data")
                             } catch GHError.invalidResponse {
                                 print("Invalid Response")
                             } catch {
                                 print("Unexpected error: \(error)")
                             }
                         }
                     }) {
                         Text("Search")
                             .font(.headline)
                             .foregroundColor(.white)
                             .padding()
                             .frame(maxWidth: .infinity)
                             .background(Color.blue)
                             .cornerRadius(10)
                             .padding(.horizontal, 40) // Padding horizontal
                     }
                     .padding(.bottom, 150)
            
        }
        
      
    }
    
    func getUser(_ userName: String) async throws -> GithubUser {
        let endpoint = "https://api.github.com/users/" + userName
        guard let url = URL(string: endpoint) else {
            throw GHError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GithubUser.self, from: data)
        } catch {
            throw GHError.invalidData
        }
    }
}

#Preview {
    ContentView()
}


struct GithubUser : Codable {
    let avatarUrl: String
    let login: String
    let bio: String
    
}


enum GHError : Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
