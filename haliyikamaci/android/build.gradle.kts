allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Provide flutter extension for legacy plugins (geolocator_android, etc.)
ext {
    set("flutter", mapOf(
        "compileSdkVersion" to 35,
        "minSdkVersion" to 24,
        "targetSdkVersion" to 35
    ))
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // Inject flutter ext ONLY for library plugins that need it.
    // DO NOT inject for "app" project as it conflicts with the real FlutterExtension.
    if (project.name != "app") {
        val flutterExt = rootProject.extensions.extraProperties.get("flutter")
        if (!project.extensions.extraProperties.has("flutter")) {
            project.extensions.extraProperties.set("flutter", flutterExt)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
