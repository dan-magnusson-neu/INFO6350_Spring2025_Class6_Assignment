import Foundation

var apiSession: CounterAPISession?
print("""
Enter a namespace and key separated by a space.
Optionally include an initial value.

<namespace> <key> [value]

If this counter does not exist, it will be created.
If it does exist, your session will switch to it.
For a list of commands, type "help".

""")

while let input = readLine() {
    let commands = input.components(separatedBy: " ")
    do {
        if commands.count > 0 {
            switch commands[0] {
            case "r", "get", "read", "peek":
                if let result = try await apiSession?.getCounterValue() {
                    print("READ: \(result)")
                } else {
                    print("Cannot read - no session set!")
                }
            case "i", "inc", "increment", "+", "++":
                if let result = try await apiSession?.incrementCounter() {
                    print("INCREMENT: \(result)")
                } else {
                    print("Cannot increment - no session set!")
                }
            case "d", "dec", "decrement", "-", "--":
                if let result = try await apiSession?.decrementCounter() {
                    print("DECREMENT: \(result)")
                } else {
                    print("Cannot decrement - no session set!")
                }
            case "u", "update", "change", ">", ">>":
                if let value = commands.count == 2 ? Int(commands[1]) : 0,
                    let result = try await apiSession?.updateCounter(to: value) {
                    print("UPDATE: \(result)")
                } else {
                    print("Cannot update - no session set!")
                }
            case "h", "help", "commands":
                print("""
                      help - prints out command list
                      <namespace> <key> [value=0] - creates or switches to a counter
                      read - reads current counter
                      increment - increments current counter
                      decrement - decrements current counter
                      update [value=0] - updates current counter
                      quit - closes the program
                      """)
            case "q", "quit", "esc", "exit":
                print("Goodbye!")
                exit(0)
            default:
                if commands.count > 1 {
                    apiSession = CounterAPISession(namespace: commands[0], key: commands[1])
                    guard let session = apiSession else { exit(0) } // CRASH: this should never happen
                    var value: Int? = nil
                    if commands.count == 3 {
                        value = Int(commands[2])
                        if value == nil {
                            print("ERROR: \(commands[2]) was not a number")
                            continue
                        }
                    }
                    let counter = try await session.getCounterValue()
                    if !(counter.exists ?? false) {
                        let result = try await session.createCounter(startingWith: value)
                        print("CREATE: \(result)")
                    } else if let value = value {
                        let result = try await session.updateCounter(to: value)
                        print("LOAD & UPDATE: \(result)")
                    } else {
                        let result = try await session.getCounterValue()
                        print("LOAD: \(result)")
                    }
                }
            }
        }
    } catch {
        print(error)
        print(error.localizedDescription)
    }
    print(" ")
}
