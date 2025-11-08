# jy-converter

A desktop application for converting between JSON and YAML formats, built with Elm and Tauri.


# Setup

```bash
# Install dependencies
npm install

# Build the Elm application
npm run build:elm

# Run in development mode
npm run dev
```

# Build for Production

```bash
npm run build
```

## Project Structure

```
jy-converter/
├── src/
│   └── Main.elm          # Elm application source
├── src-tauri/            # Tauri backend
│   ├── src/
│   │   └── main.rs       # Rust main file
│   └── tauri.conf.json   # Tauri configuration
├── dist/                 # Built frontend files
├── index.html            # HTML entry point
├── main.js               # JavaScript bridge for Elm ports
└── elm.json              # Elm dependencies
```
