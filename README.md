# PokéWorld 🌐

PokéWorld is a futuristic, scanner-themed Pokédex application built with Flutter. It utilizes the [PokéAPI](https://pokeapi.co/) to fetch comprehensive data about Pokémon and presents it in a sleek, sci-fi aesthetic with dynamic colors and glowing neon elements.

## ✨ Features

* **Scanner Aesthetic (Dark Mode Only)**: A fully custom, highly immersive UI featuring glowing radial backgrounds, tech-grid painters, and HUD-like data chips. The app exclusively runs in dark mode to maintain its futuristic theme.
* **Dynamic Theming**: The app's accent colors (neon borders, glow effects, charts, buttons) dynamically adapt based on the selected Pokémon's type (e.g., Red/Orange for Fire, Blue for Water, Green for Grass).
* **Comprehensive Pokédex**: Browse, search, and filter through over 1000+ Pokémon.
* **In-Depth Details**: 
  * **Stats**: Visualized using scanner-like progress bars.
  * **Evolution Chain**: A beautifully mapped out, interactive evolution tree.
  * **Shiny Forms**: View rare shiny variants with special UI highlights.
  * **Moves & Abilities**: Detailed info on what makes each Pokémon unique.
* **Favorites System**: Save your favorite Pokémon locally and view them instantly in the dedicated Favorites tab.
* **Smooth Animations**: Seamless hero transitions, scanning lines, and pulsing radar animations.

## 🛠️ Tech Stack

* **Framework**: [Flutter](https://flutter.dev/)
* **Language**: Dart
* **State Management**: `Provider`
* **API**: [PokéAPI](https://pokeapi.co/)
* **Local Storage**: `SharedPreferences` (for Favorites)
* **Networking**: `http`
* **Media Handling**: `cached_network_image`, `audioplayers`

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version recommended)
- Android Studio / VS Code
- An Android Emulator or physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/pokeworld.git
   cd pokeworld
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🎨 Design Philosophy

The app departs from the traditional bright and colorful Pokémon app designs. Instead, it adopts a **"Global Database / Hacker / Sci-Fi"** theme. 
- The background incorporates a custom `CustomPaint` grid to simulate a digital scanning interface.
- Cards and containers use `BoxShadow` to create intense neon glows that match the primary type of the displayed Pokémon.
- System fonts and spacing are styled to resemble computer terminal readouts (e.g., uppercase text, wide letter spacing, and mono-style numerical data).

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).

---
*Disclaimer: Pokémon and Pokémon character names are trademarks of Nintendo. This app is an unofficial, non-commercial project created for educational purposes.*
