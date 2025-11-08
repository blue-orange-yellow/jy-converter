# jy-converter

A desktop application for converting between JSON and YAML formats, built with Elm and Tauri.

## Features

- Bidirectional conversion between JSON and YAML
- Real-time syntax validation and error messages
- Dark/Light theme support
- Copy results to clipboard
- Native desktop application with minimal resource usage

## Technology Stack

- Frontend: Elm with elm-ui
- Desktop Runtime: Tauri
- YAML Processing: js-yaml library

## Development

### Prerequisites

- Node.js (v14 or later)
- Elm (0.19.1)
- Rust (for Tauri)

### Setup

```bash
# Install dependencies
npm install

# Build the Elm application
npm run build:elm

# Run in development mode
npm run dev
```

### Build for Production

```bash
npm run build
```

The compiled application will be available in `src-tauri/target/release/`.

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
