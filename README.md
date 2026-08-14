# TV Time

A Flutter movie and TV series tracking application developed as a course project for **Mobile Programming – Sharif University of Technology**.

**Student ID:** 403110541

TV Time allows users to discover movies and TV series, track their watching progress, rate titles, write reviews, create personal lists, and manage their profile.

> This project is developed for educational purposes and is not affiliated with the commercial TV Time application, TMDB, IMDb, or OMDb.

---

## Features

### Authentication

- Local user registration
- Login and logout
- Guest mode
- Persistent login session
- Password recovery using EmailJS
- Verification code flow
- Password reset
- Change password
- Profile editing
- Optional profile image
- User biography

### Home

The Home screen contains multiple discovery sections:

- Popular movies and TV series
- New releases
- Top-rated titles
- Recommended titles

Movie and TV information is fetched from TMDB.

### Search

Users can search for movies and TV series using:

- Title
- Actor
- Director
- Genre
- Release year

The search screen also supports:

- Search debounce
- Pagination
- Duplicate-result prevention
- Movie and TV result detection

### Movie Details

Movie detail pages display:

- Title
- Original title
- Poster
- Backdrop
- Story overview
- Release year
- Runtime
- Genres
- Countries
- Director
- Cast
- TMDB rating
- TMDB vote count
- IMDb rating
- IMDb vote count

IMDb information is retrieved through OMDb when available.

### TV Series Details

Series pages include:

- Series title
- Original title
- Poster and backdrop
- Story overview
- Genres
- Status
- First air year
- Last air year
- Number of seasons
- Number of episodes
- Creators
- Cast
- TMDB rating
- IMDb rating
- Seasons

### Seasons and Episodes

Users can browse every season and its episodes.

Each episode may display:

- Episode number
- Episode title
- Air date
- Runtime
- Episode image
- Rating
- Overview

Logged-in users can mark released episodes as watched or unwatched.

Series progress is automatically calculated from watched and released episodes.

### Watch Tracking

A user can assign a personal watch status to a movie or TV series.

Supported states include:

- Planned
- Watching
- Watched
- Paused
- Dropped
- No status

Users can also add or remove titles from Favorites.

### Watchlist

The Watchlist groups tracked media into dedicated sections so users can quickly view their current activity.

### Ratings

Logged-in users can rate movies and TV series from **1 to 5 stars**.

The application displays:

- User rating
- Average rating
- Total rating count
- Rating distribution
- Percentage for each star value

Existing ratings can be edited.

### Reviews

Users can:

- Write a review
- Edit their existing review
- Mark a review as containing spoilers

Spoiler reviews written by other users remain hidden until the viewer explicitly chooses to reveal them.

### Custom Lists

Users can create personal lists and add movies or TV series to them.

Features include:

- Creating lists
- Adding media to multiple lists
- Removing media from lists
- Viewing list contents
- Opening movie/series details directly from a list

### Profile and Statistics

The profile contains personal account information and activity statistics.

Statistics include:

- Watched movies
- Watched series
- Watched episodes
- Total watch time
- Favorite genre
- Average personal rating
- Followed series
- Favorites
- Number of ratings

---

## Architecture

The project follows a lightweight **MVP (Model – View – Presenter)** architecture combined with a Service Layer.

```text
lib/
├── models/
├── presenters/
├── repositories/
├── services/
├── routes/
├── utils/
├── widgets/
├── views/
├── app.dart
└── main.dart
```

### Model

Contains application data structures such as movies, series, episodes, users, ratings, reviews, and custom lists.

### View

Flutter screens and reusable widgets responsible for displaying application data and handling UI interactions.

### Presenter

Acts as the communication layer between Views and repositories/services.

### Repository

Provides data-access abstraction for remote APIs and local application data.

### Service Layer

Contains services such as:

- TMDB communication
- OMDb communication
- EmailJS password recovery
- Authentication
- Local database
- Secure storage
- Profile image management

### Service Locator

A simple static Service Locator is used to provide application services and presenters.

---

## Technologies

- Flutter
- Dart
- Material 3
- SQLite / `sqflite`
- Flutter Secure Storage
- HTTP
- Cached Network Image
- Image Picker
- Google Fonts
- TMDB API
- OMDb API
- EmailJS

---

## Local Data

This project is the normal course-project version and does not require a custom backend server.

Application-specific user data is stored locally.

SQLite is used for structured local information such as:

- Users
- Watch status
- Favorites
- Episode progress
- Ratings
- Reviews
- Custom lists

Sensitive session information is stored using Flutter Secure Storage.

---

## External Services

### TMDB

TMDB is used as the primary source for:

- Movies
- TV series
- Search
- Posters
- Backdrops
- Cast
- Seasons
- Episodes
- Discovery information

### OMDb

OMDb is used to supplement detail pages with IMDb information when an IMDb ID is available.

### EmailJS

EmailJS is used for sending password recovery verification codes.

---

## Environment Variables

API credentials are **not committed directly into the source code**.

The application expects the following Dart environment variables:

```text
TMDB_TOKEN
OMDB_API_KEY
EMAILJS_SERVICE_ID
EMAILJS_TEMPLATE_ID
EMAILJS_PUBLIC_KEY
```

Do not commit real credentials to a public Git repository.

---

## Running the Project

Install dependencies:

```bash
flutter pub get
```

Run the application with the required configuration:

```bash
flutter run \
  --dart-define=TMDB_TOKEN="YOUR_TMDB_TOKEN" \
  --dart-define=EMAILJS_SERVICE_ID="YOUR_EMAILJS_SERVICE_ID" \
  --dart-define=EMAILJS_TEMPLATE_ID="YOUR_EMAILJS_TEMPLATE_ID" \
  --dart-define=EMAILJS_PUBLIC_KEY="YOUR_EMAILJS_PUBLIC_KEY" \
  --dart-define=OMDB_API_KEY="YOUR_OMDB_API_KEY"
```

---

## Code Quality

Before running or submitting the project:

```bash
dart format lib
flutter analyze
flutter test
```

Expected final analysis result:

```text
No issues found!
```

All automated tests should pass.

---

## Launcher Icon and Splash Screen

The project contains a custom **TV Time** visual identity.

The launcher icon uses an Android adaptive icon with:

- Dark background
- Purple television
- Gold play symbol
- Gold clock detail

The native splash screen uses the same branding with a dark cinema-style background.

Icon and splash assets are located in:

```text
assets/icons/
```

---

## UI Design

The application uses a custom dark cinema theme.

Main palette:

```text
Background       #0D0D12
Surface          #17171F
Primary          #7C5CFC
Primary Light    #A78BFA
Rating / Gold    #F5C451
Success          #42C983
Error            #EF5350
```

The interface supports RTL layouts and Persian text while media titles and external metadata can be displayed using their original direction.

---

## Security Notes

API values are passed using `--dart-define` instead of being stored directly in the Git repository.

Because this version communicates directly with third-party APIs from a Flutter client, values included in a compiled client application should not be considered equivalent to server-side secrets.

EmailJS uses its public client key as intended by its client-side integration.

For a production system, sensitive operations should be moved to a secure backend.

---

## Testing

The project contains automated Flutter tests.

Run:

```bash
flutter test
```

In addition to automated tests, the following application flows were manually tested:

- Splash
- Authentication
- Guest mode
- Home
- Search
- Movie details
- TV series details
- Seasons
- Episode tracking
- Watchlist
- Favorites
- Ratings
- Reviews
- Spoilers
- Custom lists
- Profile
- Statistics
- Password recovery
- Logout and login

---

## Project Status

The normal version of the Mobile Programming course project is implemented.

Core features, local persistence, external API integration, authentication, media tracking, statistics, custom lists, ratings, reviews, responsive dark UI, launcher icon, and splash screen are included.

---

## Repository

```text
https://github.com/Tasmadi/403110541_movie_tracker_app
```

---

## Academic Project

**Course:** Mobile Programming  
**University:** Sharif University of Technology  
**Student ID:** 403110541  
**Framework:** Flutter
