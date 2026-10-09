import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// The upload key, read from android/key.properties (gitignored; the password
// and the keystore are recorded together in secrets/android-upload-key.json).
// Absent on a machine that has never published, so release signing falls back
// to the debug key there rather than failing the build.
val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}
val hasUploadKey = keystoreProperties.getProperty("storeFile") != null

// The fallback above is a convenience for `flutter run --release` on a clean
// clone, and it is also exactly how a debug-signed artefact reaches Play.
// So the Play artefact specifically refuses to build without the real key.
if (!hasUploadKey) {
    gradle.taskGraph.whenReady {
        if (allTasks.any { it.path.endsWith(":bundleRelease") }) {
            throw GradleException(
                "No upload key. android/key.properties is missing, so this " +
                "bundle would be signed with the debug key and Play would " +
                "reject it. See secrets/android-upload-key.json."
            )
        }
    }
}

android {
    namespace = "com.fe4raccoons.mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications uses java.time, which does not exist
        // below API 26. Without this the Android build fails outright with
        // "requires core library desugaring to be enabled", which is how this
        // was found: the iOS build is happy and says nothing.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.fe4raccoons.mobile"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasUploadKey) {
            create("upload") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // Play refuses a debug-signed bundle outright, which is what
            // Flutter's default here would have shipped.
            signingConfig = signingConfigs.getByName(
                if (hasUploadKey) "upload" else "debug"
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
