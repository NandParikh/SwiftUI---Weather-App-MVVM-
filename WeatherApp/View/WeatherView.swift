//
//  WeatherView.swift
//  WeatherApp
//
//  Created by                     Nand Parikh on 10/11/25.
//

import SwiftUI

struct WeatherView: View {
    
    @State private var vm = WeatherViewModel()
    @State var useFarenheit = false
    
    var body: some View {
        NavigationStack{
            VStack{
                TextField("Enter city name", text: $vm.city)
                    .textFieldStyle(.roundedBorder)
                    .padding(8)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(style: StrokeStyle(lineWidth: 1))
                        
                    }.padding()
                
                Button {
                    Task{
                        
                        await vm.fetch()
                    }
                    
                } label: {
                    Label("Get Weather", systemImage: "cloud.sun.fill")
                }.buttonStyle(.borderedProminent)
                    .padding()
                    .disabled(vm.city.count < 3)
                
                if vm.isLoading {
                    ProgressView("Fetching Weather...")
                        .padding()
                }else if let weather = vm.weatherResponse{
                    WeatherCard(weather: weather, useFahrenheit: useFarenheit)
                }
                
                if vm.errorMessage != nil {
                    ErrorMessageView()
                }
                
                Spacer()
            }
            .navigationTitle("Weather App")
            .toolbar {
                ToolbarItem {
                    Menu {
                        Toggle(isOn: $useFarenheit) {
                            Label(useFarenheit ? "Use Celsius" : "Use Farenheit", systemImage: "thermometer.sun")
                        }
                        
                    } label: {
                        Image(systemName: "gear")
                    }
                    
                }
            }
        }
    }
}

#Preview {
    WeatherView()
}
