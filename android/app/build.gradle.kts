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
  
  // AndroidX dependencies for edge-to-edge support
  implementation("androidx.core:core-ktx:1.12.0")
  implementation("androidx.activity:activity:1.8.2")
}

android {
    namespace = "com.redtea.minddrift"
    compileSdk = 35
    ndkVersion = "27.0.12077973"
    
    // Fix for 16KB native library alignment
    packaging {
        jniLibs {
            useLegacyPackaging = false
            // Enable 16KB page size alignment for native libraries
            pickFirsts += "**/libc++_shared.so"
            pickFirsts += "**/libjsc.so"
        }
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
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
        versionCode = 37
        versionName = "2.2.1"
        
        // Enable edge-to-edge support
        resConfigs("en", "ar") // Specify supported languages for optimization
        
        // Enable 16KB page size support
        ndk {
            abiFilters += listOf("arm64-v8a", "armeabi-v7a", "x86_64")
        }
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
