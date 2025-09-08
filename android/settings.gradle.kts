pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    val properties = java.util.Properties()
    file("local.properties").inputStream().use { properties.load(it) }
    val flutterSdkPath = properties.getProperty("flutter.sdk")
    require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
}

dependencyResolutionManagement {
    
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.6.0" apply false
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
    id("com.google.gms.google-services") version "4.4.3" apply false
}

rootProject.name = "upashtit2"
include(":app")
