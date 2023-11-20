Template for creating Google Cloud Run applications in Dart. Based on documentation from https://github.com/GoogleCloudPlatform/functions-framework-dart.

The functions framework is nice for very simple applications, but isn't great if you want more control over your server behavior.

## Prerequisites
- Have a general idea how to set up Cloud Run. This is not comprehensive documentation.

## Usage
1. Create a new project based on this template
2. Compose your server in `bin/server.dart`
3. Edit `deploy.sh` to use the desired parameters
4. Run `deploy.sh` to deploy your application