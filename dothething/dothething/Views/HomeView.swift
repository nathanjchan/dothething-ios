//
//  HomeView.swift
//  dothething
//
//  Created by Nathan Chan on 10/19/22.
//

import SwiftUI

struct Trapezoid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY - 93))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + 93))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

struct Staple: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + 8, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + 8, y: rect.minY + 8))
        path.addLine(to: CGPoint(x: rect.maxX - 8, y: rect.minY + 8))
        path.addLine(to: CGPoint(x: rect.maxX - 8, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

struct HomeView: View, KeyboardReadable {
    @ObservedObject private(set) var homeViewModel: HomeViewModel
    @Binding var code: String
    @Binding var toggle: Bool
    @State private var isKeyboardVisible: Bool = false

    var body: some View {
        VStack {
            ZStack {
                Trapezoid()
                    .fill(Color.accentColor)
                    .frame(width: 341, height: 270)
                
                Staple()
                    .fill(Color.accentColor)
                    .frame(width: 171, height: 112)
                    .offset(x: 0, y: -100)
                
                Staple()
                    .fill(Color.accentColor)
                    .colorInvert()
                    .frame(width: 171, height: 112)
                    .offset(x: 0, y: -100)
                    .mask(Trapezoid().frame(width: 341, height: 270))
                
                Staple()
                    .fill(Color.accentColor)
                    .frame(width: 171, height: 112)
                    .rotationEffect(.degrees(180))
                    .offset(x: 0, y: 100)
                
                Staple()
                    .fill(Color.accentColor)
                    .colorInvert()
                    .frame(width: 171, height: 112)
                    .rotationEffect(.degrees(180))
                    .offset(x: 0, y: 100)
                    .mask(Trapezoid().frame(width: 341, height: 270))
                
                Text("domino")
                    .font(.custom("Montserrat-Medium", size: 56, relativeTo: .title))
                    .foregroundColor(.accentColor)
                    .colorInvert()
                    .tracking(16)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 100)
            .padding(.bottom, 50)
            .opacity(isKeyboardVisible ? 0 : 1)
            
            Spacer()
                        
            Button(action: {
                code = ""
                toggle.toggle()
            }) {
                Text("start a rally")
                    .font(.custom("Montserrat-Light", size: 24, relativeTo: .title))
                    .foregroundColor(.accentColor)
                    .colorInvert()
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(50)
            }
            .opacity(isKeyboardVisible ? 0 : 1)
            .padding(.bottom, 8)
            
            Text("join an existing rally:")
                .font(Font.custom("Montserrat-LightItalic", size: 18, relativeTo: .caption))
            
            TextField("enter rally code", text: $code)
                .font(Font.custom("Montserrat-Light", size: 24, relativeTo: .title))
                .cornerRadius(50)
                .frame(width: 300, height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.accentColor, lineWidth: 4)
                )
                .multilineTextAlignment(.center)
                .onSubmit {
                    if code.count == 7 || code == "dothethingtest" {
                        toggle.toggle()
                    }
                }
                .keyboardType(.alphabet)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onReceive(keyboardPublisher) { newIsKeyboardVisible in
                    isKeyboardVisible = newIsKeyboardVisible
                }
            
            Text("cancel")
                .font(Font.custom("Montserrat-LightItalic", size: 18, relativeTo: .caption))
                .opacity(isKeyboardVisible ? 1 : 0)
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .padding(.bottom, isKeyboardVisible ? 250 : 100)
                .offset(x: 100)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(homeViewModel: HomeView.HomeViewModel(), code: .constant(""), toggle: .constant(true))
    }
}

extension HomeView {
    class HomeViewModel: ObservableObject {
        init() {
            print("Initializing HomeViewModel")
        }
    }
}
