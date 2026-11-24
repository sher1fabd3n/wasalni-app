import java.util.Properties
import java.io.File
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

fun trimProp(value: Any?): String = value?.toString()?.trim().orEmpty()

val storeRel = trimProp(keystoreProperties["storeFile"])
val storeFileResolved: File? = if (storeRel.isNotEmpty()) file(storeRel) else null
val hasReleaseSigning =
    keystorePropertiesFile.exists() &&
        trimProp(keystoreProperties["storePassword"]).isNotEmpty() &&
        trimProp(keystoreProperties["keyPassword"]).isNotEmpty() &&
        trimProp(keystoreProperties["keyAlias"]).isNotEmpty() &&
        storeFileResolved != null &&
        storeFileResolved.isFile

android {
    namespace = "com.waslny.users"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.waslny.users"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (hasReleaseSigning) {
                keyAlias = trimProp(keystoreProperties["keyAlias"])
                keyPassword = trimProp(keystoreProperties["keyPassword"])
                storePassword = trimProp(keystoreProperties["storePassword"])
                storeFile = storeFileResolved
            }
        }
    }

    buildTypes {
        release {
            signingConfig =
                if (hasReleaseSigning) {
                    signingConfigs.getByName("release")
                } else {
                    signingConfigs.getByName("debug")
                }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
