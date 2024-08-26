//
//  ContentView.swift
//  Game-Lists-Project 5
//
//  Created by Jesse Sheehan on 8/3/24.
//

import SwiftUI


struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var score = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    //number of words need before they turn blue and earn double points
    private var higherScore = 12
    
    var body: some View {
        NavigationStack {
            
            List {
                Section("Score: \(score)") {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                                .foregroundStyle(usedWords.count > higherScore ? .blue  : .black)
                                
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .toolbar{
                Button("Start Over", action: startGame)
            }
            .alert(errorTitle, isPresented: $showingError) {
                //if you don't write "Button("OK"), it'll add it in anyway - you still need the brackets though
                Button("OK"){}
            }message: {
                Text(errorMessage)
            }
        }
    }
        
    func addNewWord() {
        //prevents us from adding words that are the same, but just has a case difference/extra space, etc
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    
        guard answer.count > 0 else {return}
        //extra validation to come later
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used Already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You cannot spell that word from '\(rootWord)'")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't make up words")
            return
        }
        
        guard isLongEnough(word: answer) else {
            wordError(title: "Word is too short", message: "Words must be 3 letter or longer")
            return
        }
        guard isNewWord(word: answer) else {
            wordError(title: "Entered root word", message: "You can't just submit the starting word")
            return
        }
        
        //THIS ADDS ANIMATION TO MAKE THINGS LOOK NICER
        withAnimation{
            usedWords.insert(answer, at: 0)
            newWord = ""
            
        }
    
        
        let bonus = usedWords.count > higherScore ? 2 : 1
        
        score += answer.count * bonus
    
            
        
        
        
    }
    
    //this finds a random word from start.txt and sets it as the root word
    //Fatal Error creates a catch in case start.txt can't be found and makes the app immediately stop working!
    
    func startGame() {
        //tell what file to look for
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            //turn file contents into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                //turn list into array of all words
                let allWords = startWords.components(separatedBy: "\n")
                //select the root word
                rootWord = allWords.randomElement() ?? "silkworm" //this shouldn't be used, but is there just in case
                score = 0
                usedWords = [String]()
                return
            }
        }
        //FATAL ERROR - something's gone wrong
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isLongEnough(word: String) -> Bool {
        if word.count < 3 {
            return false
        }
        return true
    }
    func isNewWord(word: String) -> Bool {
        if word == rootWord {
            return false
        }
        return true
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    
    
    
}

//func testString() {
//    let word = "swift"
//    let checker = UITextChecker()
//    //swift UIKit uses objective C, you have to trick it into using it.
//    let range = NSRange(location: 0, length: word.utf16.count)
//    let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
//    
//    //NSNotfound is return if there are no misspelled words
//    
//    let allGod = misspelledRange.location == NSNotFound
//    
//    
//    //MAKING STRINGS MORE USEABLE/READABLE
//    let input = "a b c"
//    let input2 = """
//        a
//        b
//        c
//        """
//    let letters = input.components(separatedBy: " ")
//    let letters2 = input2.components(separatedBy: "\n")
//    
//    let letter = letters.randomElement() //common to use 'if let' in case array was empty or didn't have what you were looking for
//    
//    let trimmed = letter?.trimmingCharacters(in: .whitespacesAndNewlines)
//}


//    func textBundles() {
//        if let fileURL = Bundle.main.url(forResource: "somefile", withExtension: "txt") {
//            if let fileContents = try? String(contentsOf: fileURL) {
//                //load and use the string now!
//            }
//        }
//    }


//struct ContentView: View {
//    
//    let people = ["Finn", "Jake", "LSP", "Ice King"]
//    
//    var body: some View {
//        List { // (0..<5) //then replace below with Text($0)
//            Section("Section 1") {
//                Text("Static Row 1")
//                Text("Static Row 2")
//            }
//            Section("Section 2") {
//                ForEach(0..<2) {
//                    Text("Dynamic Row \($0)")
//                }
//            }
//            Section("Section 3") {
//                Text("Static Row").bold()
//                ForEach(people, id: \.self) {
//                    Text($0)
//                }
//            }
//            
//        }.listStyle(.grouped)
//        //Lists can create dynamic content and tell SwiftUI how each item is different, too
//     
////        List(people, id: \.self) {
////            Text($0)
////        }
//    }
//}

#Preview {
    ContentView()
}
