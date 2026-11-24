allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // Keep plugin build dirs on the same drive as the plugin sources.
    // Pub-cache plugins usually live on C: while this app is on D:. Remapping
    // those build dirs to D:\users_app\build\<plugin> makes AGP fail Android
    // Studio sync with "this and base files have different roots" when creating
    // generateDebugUnitTestConfig.
    val sourceRoot = project.projectDir.toPath().root
    val destRoot = newBuildDir.asFile.toPath().root
    if (sourceRoot == destRoot) {
        project.layout.buildDirectory.value(newBuildDir.dir(project.name))
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
