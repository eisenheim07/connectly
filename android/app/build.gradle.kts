plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.connectly"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.connectly"
        minSdk = 21
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Option A: Try JitPack first (comment out if using local AAR files)
    // implementation("com.github.aws.amazon-chime-sdk-android:amazon-chime-sdk:0.25.3")
    // implementation("com.github.aws.amazon-chime-sdk-android:amazon-chime-sdk-media:0.25.3")
    
    // Option B: Local AAR files (place AAR files in android/app/libs/)
    implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("*.aar"))))
    
    // Required dependencies
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.0")
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("com.google.code.gson:gson:2.10.1")
}
