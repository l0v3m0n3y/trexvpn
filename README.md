# trexvpn
api for t-rex vpn T-Rex VPN - Connect 10x faster with military-grade encryption. Protect your privacy, unblock content, and enjoy unlimited bandwidth on 50+ countries
# main
```swift
import Foundation
import trexvpn
let client = Trexvpn()

do {
    let login_data = try await client.login(email: <email>,password: <password>)
    print(login_data)
} catch {
    print("Error: \(error)")
}
```

# Launch (your script)
```
swift run
```
