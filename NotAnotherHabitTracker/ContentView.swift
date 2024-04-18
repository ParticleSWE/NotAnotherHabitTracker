//
//  ContentView.swift
//  NotAnotherHabitTracker
//
//  Created by Patrik Ell on 2024-04-12.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var justLaunched = true
    
    @State private var rotationAngle: Double = 0
    @State private var gearRotationAngle: Double = 0
    @State private var calendarScaleEffect: Double = 1
    @State private var listYPosition = 0
    @State private var isAnimating = false
    @State private var selectedHabit = "Placeholder"
    @AppStorage("SavedHabit") var presentedHabit = "NotAnotherHabitTracker"
    
    @State private var presentCalendar = false
    @State private var presentList = false
    @State private var presentSettings = false
    @State private var selectedDate = Date()
    @State private var newHabitName = ""
    
    @State private var addItemAnimation = ["goodBoy", "rocket", "jakeApproves"]
    @State private var xPosition = 0
    @State private var yPosition = 500
    @State private var randomAnimationInt = 0

    @State private var screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationStack {
            if justLaunched == true {
                LaunchScreenView(justLaunched: $justLaunched)
            }
            else {
                VStack {
                    Text(presentedHabit).font(.custom("Chalkduster", size: 48)).foregroundStyle(.white).minimumScaleFactor(0.2).lineLimit(1)
                    HStack {
                        Button {
                            presentList.toggle()
                        } label: {
                            Image("listButton").resizable().scaledToFit().offset(y: CGFloat(listYPosition))
                        }.sheet(isPresented: $presentList, content: {
                            VStack {
                                let uniqueHabitNames = Set(items.map { $0.nameOfHabit })
                                List {
                                    Section {
                                        ForEach(uniqueHabitNames.sorted(), id: \.self) { listedHabits in
                                            HStack {
                                                let theHabitsCount = items.filter { $0.nameOfHabit == listedHabits }.count
                                                Text(listedHabits)
                                                Text("\(theHabitsCount)")
                                            }
                                        }
                                    } header: {
                                        Text("All habits:")
                                    }
                                    Section {
                                        ForEach(items.filter {$0.nameOfHabit == presentedHabit}, id: \.self) { currentHabit in
                                            VStack(alignment: .leading) {
                                                Text(currentHabit.nameOfHabit)
                                                Text("\(formattedDate(from: currentHabit.datesCompleted))")
                                            }
                                        }.onDelete(perform: deleteItems)
                                    } header: {
                                        Text("Current habit:")
                                    }
                                }
                            }
                        })
                        Spacer()
                        Button {
                            presentCalendar.toggle()
                        } label: {
                            Image("calendarButton").resizable().scaledToFit().scaleEffect(calendarScaleEffect)
                        }.sheet(isPresented: $presentCalendar, content: {
                            VStack {
                                DatePicker("Add dates", selection: $selectedDate, displayedComponents: .date).datePickerStyle(.graphical)
                                Button("Save", action: {
                                    addItem()
                                }).buttonStyle(.borderedProminent)
                            }.padding()
                        })
                        
                        Spacer()
                        Button {
                            if presentedHabit != "NotAnotherHabitTracker" {
                                selectedDate = Date()
                                addItem()
                            }
                        } label: {
                            Image("plusButton").resizable().scaledToFit().rotationEffect(.degrees(rotationAngle)).offset(x: CGFloat(xPosition))
                        }
                        Spacer()
                        Button {
                            presentSettings.toggle()
                        } label: {
                            Image("settingsGear").resizable().scaledToFit().rotationEffect(.degrees(gearRotationAngle))
                        }.sheet(isPresented: $presentSettings, content: {
                            VStack {
                                Text("Add new habit:")
                                HStack {
                                    TextField("Habit...", text: $newHabitName).textFieldStyle(.roundedBorder)
                                    Button("Save", action: {
                                        if newHabitName != "" {
                                            presentedHabit = newHabitName
                                            addItem()
                                            newHabitName = ""
                                        }
                                    }).buttonStyle(.borderedProminent)
                                }
                                if items.count > 0 {
                                    Text("or pick a habit:")
                                    Picker("Habit:", selection: $selectedHabit) {
                                        let uniqueHabitNames = Set(items.map { $0.nameOfHabit })
                                        ForEach(uniqueHabitNames.sorted(), id: \.self) { habit in
                                            Text(habit)
                                        }
                                    }.onChange(of: selectedHabit) {
                                        if selectedHabit != presentedHabit {
                                            presentedHabit = selectedHabit
                                        }
                                    }
                                }
                            }.padding()
                        })
                    }.frame(width: screenWidth - 80, height: 50)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: screenWidth/7.5, maximum: 60))], alignment: .center, spacing: 20, content: {
                        let filteredItems = items.filter { $0.nameOfHabit == presentedHabit }
                        
                        if filteredItems.count > 4 {
                            let amountOfFives = filteredItems.count / 5
                            ForEach(1...amountOfFives, id: \.self) { numberOfDays in
                                Image("05").resizable().scaledToFit()
                            }
                        }
                        
                        if filteredItems.count > 0 {
                            let numberOfFives = filteredItems.count / 5
                            let singleNumbers = filteredItems.count - (numberOfFives * 5)
                            if singleNumbers == 1 {
                                Image("01").resizable().scaledToFit()
                            }
                            if singleNumbers == 2 {
                                Image("02").resizable().scaledToFit()
                            }
                            if singleNumbers == 3 {
                                Image("03").resizable().scaledToFit()
                            }
                            if singleNumbers == 4 {
                                Image("04").resizable().scaledToFit()
                            }
                        }
                    })
                    if items.count == 0 {
                        VStack {
                            Text("Welcome to Habit Hell!").foregroundStyle(.white).font(.title2).bold()
                            Text("The app designed to help you MAKE or BREAK habits.\nTo begin tracking your habits, please press the gear on the right to add a habit.\nThen you simply tap the plus button each day that you've successfully kept up doing or avoiding a habit.\nThe app is designed to look like a prison cell wall that you draw one line on for each day you're successful, since making or breaking a habit really can feel like a chore or a punishment.").foregroundStyle(.white).font(.title3).bold()
                            Text("Good luck!!").foregroundStyle(.white).font(.title2).bold()
                        }.shadow(radius: 5).shadow(radius: 5).fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Image("\(addItemAnimation[randomAnimationInt])").resizable().scaledToFit().offset(y: CGFloat(yPosition))
                }.padding().background(Image("concreteWall")).onAppear {
                    startRotationAnimation()
                    gearRotationAnimation()
                    calendarAnimation()
                    listAnimation()
                }
            }
        }
    }

    private func addItem() {
        randomAnimationInt = Int.random(in: 0...2)
        withAnimation {
            let newItem = Item(datesCompleted: selectedDate, nameOfHabit: presentedHabit)
            modelContext.insert(newItem)
            withAnimation(Animation.easeOut(duration: 0.5)) {
                if randomAnimationInt == 2 {
                    yPosition = 50
                }
                else {
                    yPosition = 60
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1300)) {
                withAnimation(Animation.easeOut(duration: 0.5)) {
                    yPosition = 500
                }
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
    
    private func startRotationAnimation() {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            withAnimation(Animation.linear(duration: 1)) {
                rotationAngle = 30
                xPosition = 7
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(Animation.linear(duration: 1)) {
                    rotationAngle = -30
                    xPosition = -7
                }
            }
        }
    }
    
    private func gearRotationAnimation() {
        Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { _ in
            withAnimation(Animation.linear(duration: 8)) {
                gearRotationAngle = 360
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                gearRotationAngle = 0
            }
        }
    }
    private func calendarAnimation() {
        Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            withAnimation(Animation.linear(duration: 2)) {
                calendarScaleEffect = 1.1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(Animation.linear(duration: 2)) {
                    calendarScaleEffect = 0.9
                }
            }
        }
    }
    private func listAnimation() {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            withAnimation(Animation.linear(duration: 1)) {
                listYPosition = 5
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(Animation.linear(duration: 1)) {
                    listYPosition = -5
                }
            }
        }
    }
    func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

