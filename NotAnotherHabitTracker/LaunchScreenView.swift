//
//  LaunchScreenView.swift
//  NotAnotherHabitTracker
//
//  Created by Patrik Ell on 2024-04-18.
//

import SwiftUI

struct LaunchScreenView: View {
    
    @Binding var justLaunched: Bool
    
    var body: some View {
        VStack {
            Divider().opacity(0.0)
            Image("HabitHellLogo").resizable().scaledToFit().shadow(radius: 10).shadow(radius: 5).shadow(radius: 3)
            Text("MAKE or BREAK").font(.custom("Chalkduster", size: 36)).minimumScaleFactor(0.2).lineLimit(1)
            Text("that habit").font(.custom("Chalkduster", size: 24)).minimumScaleFactor(0.2).lineLimit(1)
            Text("NOW!").font(.custom("Chalkduster", size: 42)).minimumScaleFactor(0.2).lineLimit(1)
            Button("Hell yeah!", action: {
                justLaunched = false
            }).font(.title).bold().padding().background(.blue).clipShape(Capsule()).shadow(color: .white, radius: 10).shadow(color: .white, radius: 10)
        }.padding().foregroundStyle(.white).background(Image("concreteWall"))
    }
}

#Preview {
    LaunchScreenView(justLaunched: .constant(true))
}
