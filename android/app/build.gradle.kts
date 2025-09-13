import java.util.Properties
import java.io.FileInputStream


plugins {
    id("com.android.application")
    // Add the Google services Gradle plugin
    id("com.google.gms.google-services")

    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ✅ LOAD key.properties
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) {
        load(file.inputStream())
    }
}

dependencies {
  // Import the Firebase BoM
  implementation(platform("com.google.firebase:firebase-bom:33.15.0"))


  // TODO: Add the dependencies for Firebase products you want to use
  // When using the BoM, don't specify versions in Firebase dependencies
  implementation("com.google.firebase:firebase-analytics")


  // Add the dependencies for any other desired Firebase products
  // https://firebase.google.com/docs/android/setup#available-libraries
}

android {
    namespace = "com.redtea.minddrift"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"
    
    // Fix for 16KB native library alignment
    packagingOptions {
        jniLibs {
            useLegacyPackaging = false
        }
    }

    signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"]?.toString()
        keyPassword = keystoreProperties["keyPassword"]?.toString()
        storeFile = keystoreProperties["storeFile"]?.toString()?.let { file(it) }
        storePassword = keystoreProperties["storePassword"]?.toString()
    }
}

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.redtea.minddrift"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = 35
        versionCode = 32
        versionName = "2.1.2"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
