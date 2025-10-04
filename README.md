# NASA APOD iOS App

A simple iOS app that shows NASA's Astronomy Picture of the Day.

## What I have Built

I have created an iOS app that fetches and displays daily space pictures from NASA. Users can see today's picture or pick any date to see what NASA posted that day. Works with both images and videos.

## What's Included

### The App Has:
- **APOD Model** - represents the data (title, image, description, date, etc.)
- **Network Service** - talks to NASA's API to fetch pictures
- **Cache Service** - saves pictures locally so you can view them offline
- **ViewModel** - handles the logic and state management
- **UI Views** - displays the pictures and info nicely
- **Unit Tests** - tests for network, cache, and viewmodel logic

### Project Structure:
```
Models/         - APOD data model
Services/       - Network calls and caching
ViewModels/     - Business logic
Views/          - UI screens
Tests/          - Unit tests
```

## How to Extend This


**1. Add New Endpoints **

In the `APIEndpoint` enum, just add a new case:

```swift
enum APIEndpoint {
    case apod           // ← Already here
    case marsPhotos     // ← Add this
    case asteroidData   // ← Or this
    
    var path: String {
        switch self {
        case .apod:
            return "/apod"
        case .marsPhotos:
            return "/mars-photos/api/v1/rovers"
        case .asteroidData:
            return "/neo/rest/v1/feed"
        }
    }
}
```


**2. Add Features:**
- **Favorites** - extend CacheService to save favorite APODs
- **Search** - add search functionality by date range
- **Mars Photos** - create a new service using the endpoint pattern
- **Share** - add share button to post images

**3. Improve Caching:**
- Currently caches in UserDefaults
- Can upgrade to CoreData or Realm for better performance
- Add image caching with NSCache


## That's It!

Clean architecture + environment config + extensible endpoints = Easy to maintain and extend.

