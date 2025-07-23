# GitHub Actions Auto Deploy Setup Guide

This guide will help you configure GitHub Actions for automatic deployment of your Flutter app to various platforms.

## Workflows Overview

### 1. **CI/CD Pipeline** (`ci-cd.yml`)
- Runs on every push and pull request
- Performs code analysis, testing, and building
- Creates releases automatically from main branch
- Builds for Web, Android APK, and Android App Bundle

### 2. **Firebase Hosting** (`firebase-hosting-merge.yml` & `firebase-hosting-pull-request.yml`)
- Deploys Flutter web app to Firebase Hosting
- Merge: Deploys to live site on main branch
- PR: Creates preview deployments for pull requests

### 3. **Google Play Store** (`deploy-play-store.yml`)
- Deploys Android app to Google Play Store
- Triggered by version tags or manual dispatch
- Supports different release tracks (internal, alpha, beta, production)

### 4. **Apple App Store** (`deploy-app-store.yml`)
- Deploys iOS app to Apple App Store
- Triggered by version tags or manual dispatch

### 5. **Security & Dependency Scan** (`security-scan.yml`)
- Runs security and dependency vulnerability scans
- Scheduled weekly and on pushes
- Generates license compliance reports

## Required GitHub Secrets

To set up these workflows, you need to configure the following secrets in your GitHub repository:

### Firebase Hosting Secrets
```
FIREBASE_SERVICE_ACCOUNT_PANEL_MONITOR_691C6
```
- Get this from Firebase Console → Project Settings → Service Accounts → Generate New Private Key

### Android Play Store Secrets
```
ANDROID_KEYSTORE_BASE64          # Your Android keystore file encoded in base64
ANDROID_KEY_ALIAS                # Key alias from your keystore
ANDROID_STORE_PASSWORD           # Keystore password
ANDROID_KEY_PASSWORD             # Key password
GOOGLE_SERVICE_ACCOUNT_JSON      # Google Play Console service account JSON
```

### iOS App Store Secrets
```
IOS_CERTIFICATE_BASE64           # iOS distribution certificate in base64
IOS_CERTIFICATE_PASSWORD         # Certificate password
IOS_PROVISIONING_PROFILE_BASE64  # Provisioning profile in base64
KEYCHAIN_PASSWORD               # Keychain password (can be any secure string)
APP_STORE_CONNECT_API_KEY_ID     # App Store Connect API Key ID
APP_STORE_CONNECT_API_ISSUER_ID  # App Store Connect API Issuer ID
APP_STORE_CONNECT_API_KEY_BASE64 # App Store Connect API Key (.p8 file) in base64
```

## Setup Instructions

### 1. Firebase Hosting Setup

1. **Generate Firebase Service Account:**
   ```bash
   # Install Firebase CLI if not already installed
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Initialize Firebase in your project
   firebase init hosting
   
   # Generate service account key
   firebase projects:list
   # Go to Firebase Console → Project Settings → Service Accounts → Generate New Private Key
   ```

2. **Add the service account JSON to GitHub Secrets:**
   - Copy the entire JSON content
   - In GitHub: Settings → Secrets → Actions → New repository secret
   - Name: `FIREBASE_SERVICE_ACCOUNT_PANEL_MONITOR_691C6`
   - Value: Paste the JSON content

### 2. Android Play Store Setup

1. **Create Android Keystore:**
   ```bash
   keytool -genkey -v -keystore android-keystore.jks -alias your-alias -keyalg RSA -keysize 2048 -validity 10000
   ```

2. **Encode keystore to base64:**
   ```bash
   # On Windows (PowerShell)
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("android-keystore.jks"))
   
   # On Linux/Mac
   base64 -i android-keystore.jks
   ```

3. **Configure Play Store API:**
   - Go to Google Cloud Console
   - Create a service account for Play Store API
   - Download the JSON key
   - Enable Google Play Developer API

4. **Add Android secrets to GitHub:**
   - `ANDROID_KEYSTORE_BASE64`: Base64 encoded keystore
   - `ANDROID_KEY_ALIAS`: Your key alias
   - `ANDROID_STORE_PASSWORD`: Keystore password
   - `ANDROID_KEY_PASSWORD`: Key password
   - `GOOGLE_SERVICE_ACCOUNT_JSON`: Play Store service account JSON

### 3. iOS App Store Setup

1. **Generate iOS certificates and profiles:**
   - Create distribution certificate in Apple Developer Console
   - Create provisioning profile for App Store distribution
   - Export certificate as .p12 file

2. **Create App Store Connect API Key:**
   - Go to App Store Connect → Users and Access → Keys
   - Create new API key with Developer role
   - Download the .p8 file

3. **Encode files to base64:**
   ```bash
   # Certificate
   base64 -i certificate.p12
   
   # Provisioning profile
   base64 -i profile.mobileprovision
   
   # API Key
   base64 -i AuthKey_XXXXXXXXX.p8
   ```

4. **Add iOS secrets to GitHub:**
   - `IOS_CERTIFICATE_BASE64`: Base64 encoded certificate
   - `IOS_CERTIFICATE_PASSWORD`: Certificate password
   - `IOS_PROVISIONING_PROFILE_BASE64`: Base64 encoded provisioning profile
   - `KEYCHAIN_PASSWORD`: Any secure password
   - `APP_STORE_CONNECT_API_KEY_ID`: API Key ID
   - `APP_STORE_CONNECT_API_ISSUER_ID`: Issuer ID
   - `APP_STORE_CONNECT_API_KEY_BASE64`: Base64 encoded .p8 file

### 4. Configure Android Package Name

Update the package name in `deploy-play-store.yml`:
```yaml
packageName: com.example.electro_app  # Change this to your actual package name
```

Check your package name in `android/app/src/main/AndroidManifest.xml`.

### 5. Version Management

The workflows use the version from `pubspec.yaml`. To trigger a release:

1. **Update version in pubspec.yaml:**
   ```yaml
   version: 1.0.1+2  # Increment version number
   ```

2. **Create and push a tag:**
   ```bash
   git add pubspec.yaml
   git commit -m "Bump version to 1.0.1"
   git tag v1.0.1
   git push origin main --tags
   ```

## Workflow Triggers

### Automatic Triggers
- **Push to main**: Triggers full CI/CD pipeline, Firebase deployment, and release creation
- **Pull requests**: Triggers CI tests and Firebase preview deployment
- **Version tags**: Triggers Play Store and App Store deployments
- **Weekly schedule**: Runs security scans every Sunday

### Manual Triggers
- All workflows can be triggered manually from GitHub Actions tab
- Play Store deployment allows selecting release track (internal/alpha/beta/production)

## Monitoring and Troubleshooting

### Check Workflow Status
- Go to GitHub repository → Actions tab
- View logs for failed runs
- Check artifact uploads for build outputs

### Common Issues
1. **Secret not found**: Ensure all required secrets are added to GitHub repository
2. **Build failures**: Check Flutter version compatibility
3. **Signing issues**: Verify certificate and keystore configurations
4. **API permissions**: Ensure service accounts have proper permissions

### Build Artifacts
- APK and AAB files are uploaded as artifacts for 30 days
- Web builds are uploaded as artifacts for 7 days
- License reports are generated and stored

## Security Best Practices

1. **Rotate secrets regularly**: Update certificates and API keys periodically
2. **Use least privilege**: Service accounts should have minimal required permissions
3. **Monitor dependencies**: Weekly security scans help identify vulnerabilities
4. **Review PRs**: All changes go through pull request review process

## Support

For issues with:
- **Firebase**: Check Firebase Console and documentation
- **Play Store**: Review Google Play Console error messages
- **App Store**: Check App Store Connect for submission status
- **GitHub Actions**: Review workflow logs and GitHub documentation
