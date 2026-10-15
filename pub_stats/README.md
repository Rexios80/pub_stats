# pubstats

Jaspr client app for [pubstats.dev](https://pubstats.dev). It reads package statistics from Firebase and pub.dev, then renders search, charts, history, and alerts in the browser.

## Running

```sh
jaspr serve
```

The development server is available at `http://localhost:8080`.

Firebase Auth and App Check for this project only accept the domains configured in Firebase. A localhost server can render the UI, but production statistics load when the site is served from an allowed host such as `pubstats.dev`.

## Building

```sh
jaspr build
```

The output is in `build/jaspr/`.
