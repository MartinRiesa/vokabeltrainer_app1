// android/app/build.gradle.kts

plugins {
    id("com.android.application")
    kotlin("android")
}

android {
    namespace = "com.example.vokabeltrainer_app"
    compileSdk = 34

    // ← WICHTIG: NDK-Version für flutter_tts
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.vokabeltrainer_app"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = "1.8"
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.0")
    implementation("androidx.core:core-ktx:1.10.1")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.9.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")

    // Flutter-Modul
    implementation(project(":flutter"))
}
