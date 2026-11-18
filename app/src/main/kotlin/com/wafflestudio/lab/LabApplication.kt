package com.wafflestudio.lab

import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import java.net.InetAddress

// Change this string and push to trigger a new deployment (lab 4).
const val MESSAGE = "Hello from bye"

@SpringBootApplication
class LabApplication

fun main(args: Array<String>) {
    runApplication<LabApplication>(*args)
}

data class HelloResponse(
    val name: String,
    val hostname: String,
    val version: String,
    val message: String,
)

@RestController
class HelloController(
    // Injected per container via the APP_NAME environment variable.
    @Value("\${APP_NAME:app}") private val name: String,
    // Baked into the image at build time (see Dockerfile). "dev" for local builds.
    @Value("\${APP_VERSION:dev}") private val version: String,
) {
    @GetMapping("/api/hello")
    fun hello() =
        HelloResponse(
            name = name,
            hostname = InetAddress.getLocalHost().hostName,
            version = version,
            message = MESSAGE,
        )
}
